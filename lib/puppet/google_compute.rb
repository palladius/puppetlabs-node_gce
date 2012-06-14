require 'oauth2'
require 'uri'

module Puppet
  class GoogleCompute
    def get_project(project_name)
      do_request(project_name, 'zones')
    end

  private

    def do_request(project_name, path)
      token.get("https://www.googleapis.com/compute/v1beta11/projects/#{URI.escape(project_name)}/#{URI.escape(path)}")
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

      raise(ArgumentError, ":client_id must be specified in credentials") unless unvalidated_credentials[:client_id]
      raise(ArgumentError, ":client_secret must be specified in credentials") unless unvalidated_credentials[:client_secret]

      raise(ArgumentError, ":refresh_token must be specified in credentials") unless unvalidated_credentials[:refresh_token]

      unvalidated_credentials
    end
  end
end
