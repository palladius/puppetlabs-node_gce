require 'oauth2'
require 'uri'
require 'yaml'

module Puppet
  class GoogleCompute
    attr_reader :project_name

    def initialize(project_name)
      @project_name = project_name
    end

    def disk_list
      get('disks')
    end

    def firewall_list
      get('firewalls')
    end

    def image_list
      get('images')
    end

    def instance_list
      get('instances')
    end

    def instance_get(params)
      get('instances', params[:name])
    end

    def instance_create(params)
      args = {
        'name'         => params[:name],
        'machineType'  => machine_type(params[:machine_type] || 'standard-1-cpu-ephemeral-disk'),
        'zone'         => zone(params[:zone] || 'us-east-a'),
        'networkInterfaces' => [  # hi, I'm undocumented!
          {
            'accessConfigs' => [ { 'type' => "ONE_TO_ONE_NAT", 'name' => "External NAT" } ],
            'network'       => network('default'),
          }
        ]
      }
      wait_for_instance(post('instances', args))
    end

    def instance_delete(params)
      wait_for(delete('instances', params[:name]))
    end

    def kernel_list
      get('kernels')
    end

    def machine_type_list
      get('machine-types')
    end

    def network_list
      get('networks')
    end

    def operation_list
      get('operations')
    end

    def operation_get(params)
      get('operations', params[:name])
    end

    def project_get
      get
    end

    def zone_list
      get('zones')
    end

  private

    def get(*path)
      token.get(build_url(*path)).body
    end

    def post(path, params)
      token.post(build_url(path)) { |request|
        request.headers['Content-Type'] = 'application/json'
        request.body = PSON.dump(params)
      }.body
    end

    def delete(*path)
      token.delete(build_url(*path)).body
    end

    def machine_type(name)
      build_url('machine-types', name)
    end

    def zone(name)
      build_url('zones', name)
    end

    def network(name)
      build_url('networks', name)
    end

    def build_url(*path)
      url = "#{api_url}/projects/#{URI.escape(project_name)}" + path_from_params(path)
    end

    def path_from_params(params)
      path = params.join('/').strip
      path == '' ? '' : "/#{URI.escape(path)}"
    end

    def api_url
      "https://www.googleapis.com/compute/v1beta11"
    end

    def wait_for(operation_json)
      operation = thaw_operation(operation_json)
      while ongoing_operation?(operation)
        sleep 3
        operation_json = operation_get(:name => operation_name(operation))
        operation = thaw_operation(operation_json)
      end
      operation_json
    end

    def wait_for_instance(operation_json)
      convert_operation_to_instance(wait_for(operation_json))
    end

    def thaw_operation(operation_json)
      operation = PSON.parse(operation_json)
      check_operation_for_error(operation)
      operation
    end

    def check_operation_for_error(operation)
      return unless operation['error']
      error_messages = operation['error']['errors'].collect {|e| e['message']}
      raise "Errors encountered:\n" + error_messages.join("\n")
    end

    def ongoing_operation?(operation)
      operation['status'] != 'DONE'
    end

    def convert_operation_to_instance(operation_json)
      operation = PSON.parse(operation_json)
      instance_get(:name => instance_name(operation['targetLink']))
    end

    def operation_name(operation)
      operation['name'].split('/').last
    end

    def instance_name(instance_url)
      instance_url.split('/').last
    end

    def token
      @token ||= authenticate
    end

    def authenticate
      new_token = OAuth2::AccessToken.from_hash(client, { :refresh_token => refresh_token })
      new_token.refresh!
    end

    def client
      @client ||= OAuth2::Client.new(
        client_id,
        client_secret,
        :site => 'https://accounts.google.com',
        :token_url => '/o/oauth2/token',
        :authorize_url => '/o/oauth2/auth')
    end

    def refresh_token
      credentials[:refresh_token]
    end

    def client_id
      credentials[:client_id]
    end

    def client_secret
      credentials[:client_secret]
    end

    def credentials
      @credentials ||= validate_credentials
    end

    def validate_credentials
      unvalidated_credentials = fetch_credentials
      raise "Missing google compute credentials in config file #{credentials_path}" unless unvalidated_credentials

      [:client_id, :client_secret, :refresh_token].each do |arg|
        raise(ArgumentError, ":#{arg} must be specified in credentials in config file #{credentials_path}") unless unvalidated_credentials[arg]
      end

      unvalidated_credentials
    end

    def fetch_credentials
      @fetched_credentials ||= load_credentials[:gce]
    end

    def load_credentials
      YAML.load(File.read(credentials_path))
    end

    def credentials_path
      File.expand_path('~/.fog')
    end
  end
end
