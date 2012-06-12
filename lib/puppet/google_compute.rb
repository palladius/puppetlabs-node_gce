module Puppet
  class GoogleCompute
    def validate_credentials(unvalidated_credentials)
      unvalidated_credentials = fetch_credentials
      raise (ArgumentError, ":client_id must be specified in credentials") unless unvalidated_credentials[:client_id]
      raise (ArgumentError, ":client_secret must be specified in credentials") unless unvalidated_credentials[:client_secret]

      if unvalidated_credentials[:refresh_token]
        raise (ArgumentError, ":expires_at must be specified in credentials") unless unvalidated_credentials[:expires_at]
      else
        raise (ArgumentError, ":verification_code must be specified in credentials") unless unvalidated_credentials[:verification_code]
      end

      unvalidated_credentials
    end

    def credentials
      @credentials ||= validate_credentials(fetch_credentials)
    end

    def do_request
      credentials
      PSON.generate({ :a => 'b', '1' => :c })
    end

    def get_project(project_name)
      do_request
    end
  end
end
