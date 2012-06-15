require 'oauth2'
require 'uri'
require 'yaml'

module Puppet
  class GoogleCompute
    def get_project(project_name)
      # this request is weird, namespace-wise
      token.get("#{api_url}/projects/#{URI.escape(project_name)}").body
    end

    def instance_list(project_name)
      do_request(project_name, 'instances')
    end

  private

    def do_request(project_name, path = '')
      token.get(build_url(project_name, path)).body
    end

    def build_url(project_name, path)
      url = "#{api_url}/projects/#{URI.escape(project_name)}"
      url += "/#{URI.escape(path)}" unless path == ''
      url
    end

    def api_url
      "https://www.googleapis.com/compute/v1beta11"
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
      YAML.load(File.read(credentials_path))[:gce]
    end

    def credentials_path
      File.expand_path('~/.fog')
    end
  end
end
