require 'oauth2'

module Puppet
  class GoogleCompute
    def get_project(project_name)
      do_request(project_name, 'project')
    end


    def validate_credentials
      unvalidated_credentials = fetch_credentials

      raise(ArgumentError, ":client_id must be specified in credentials") unless unvalidated_credentials[:client_id]
      raise(ArgumentError, ":client_secret must be specified in credentials") unless unvalidated_credentials[:client_secret]

      if unvalidated_credentials[:refresh_token]
        raise(ArgumentError, ":expires_at must be specified in credentials") unless unvalidated_credentials[:expires_at]
      else
        raise(ArgumentError, ":verification_code must be specified in credentials") unless unvalidated_credentials[:verification_code]
      end

      unvalidated_credentials
    end

    def credentials
      @credentials ||= validate_credentials
    end

    def client_id
      credentials[:client_id]
    end

    def client_secret
      credentials[:client_secret]
    end

    def refresh_token
      credentials[:refresh_token]
    end

    def expires_at
      credentials[:expires_at]
    end

    def client
      @client ||= OAuth2::Client.new(client_id, client_secret, :site => 'https://accounts.google.com', :token_url => '/o/oauth2/token', :authorize_url => '/o/oauth2/auth')
    end

    def verification_code
      credentials[:verification_code]
    end

    def has_refresh_token?
      !! credentials[:refresh_token]
    end

    def authenticate_with_refresh_token
      new_token = OAuth2::AccessToken.from_hash(client, { :refresh_token => refresh_token, :expires_at => expires_at })
      new_token.refresh!
    end

    def authenticate_without_refresh_token
      new_uri = client.auth_code.get_token(verification_code, :redirect_uri => redirect_uri)
      raise(ArgumentError, "Please go to this URL, authorize the application, and store the verification code as :verification_code in your credentials file.\n#{new_uri}\n")
    end

    def authenticate
      if has_refresh_token?
        authenticate_with_refresh_token
      else
        authenticate_without_refresh_token
      end
    end

    def token
      @token ||= authenticate
    end

    def do_request(project_name, path)
      token.get("https://www.googleapis.com/compute/v1beta11/projects/#{project_name}/#{path}")
    end

    def redirect_uri
      @redirect_uri ||= 'urn:ietf:wg:oauth:2.0:oob'
    end

    def scope
      @scope ||= "https://www.googleapis.com/auth/compute https://www.googleapis.com/auth/compute.readonly https://www.googleapis.com/auth/devstorage.full_control https://www.googleapis.com/auth/devstorage.read_only https://www.googleapis.com/auth/devstorage.read_write https://www.googleapis.com/auth/devstorage.write_only https://www.googleapis.com/auth/userinfo.email"
    end
  end
end
