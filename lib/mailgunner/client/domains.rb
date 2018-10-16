# frozen_string_literal: true

module Mailgunner
  class Client
    def get_domains(params = {})
      get('/v3/domains', params)
    end

    def get_domain(name)
      get("/v3/domains/#{escape name}")
    end

    def add_domain(attributes = {})
      post('/v3/domains', attributes)
    end

    def delete_domain(name)
      delete("/v3/domains/#{escape name}")
    end

    def get_credentials
      get("/v3/domains/#{escape @domain}/credentials")
    end

    def add_credentials(attributes)
      post("/v3/domains/#{escape @domain}/credentials", attributes)
    end

    def update_credentials(login, attributes)
      put("/v3/domains/#{escape @domain}/credentials/#{escape login}", attributes)
    end

    def delete_credentials(login)
      delete("/v3/domains/#{escape @domain}/credentials/#{escape login}")
    end

    def get_connection_settings
      get("/v3/domains/#{escape @domain}/connection")
    end

    def update_connection_settings(attributes)
      put("/v3/domains/#{escape @domain}/connection", attributes)
    end
  end
end
