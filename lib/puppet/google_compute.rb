require 'oauth2'
require 'uri'
require 'yaml'

module Puppet
  class GoogleCompute
    attr_reader :project_name

    def initialize(project_name)
      @project_name = project_name
    end

    def project_get
      get
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
        'machineType'  => machine_type('standard-1-cpu'),
        'zone'         => zone('us-east-b'),
        'networkInterfaces' => [  # hi, I'm undocumented!
          {
            'accessConfigs' => [ { 'type' => "ONE_TO_ONE_NAT", 'name' => "External NAT" } ],
            'network'       => network('default'),
          }
        ]
      }
      post('instances', args)
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

      [:client_id, :client_secret, :refresh_token].each do |arg|
        raise(ArgumentError, ":#{arg} must be specified in credentials") unless unvalidated_credentials[arg]
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
