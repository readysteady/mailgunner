# frozen_string_literal: true

module Mailgunner
  class Client
    def get_domains(params = PARAMS)
      get('/v3/domains', query: params)
    end

    def get_domain(name)
      get("/v3/domains/#{escape name}")
    end

    def add_domain(attributes = ATTRIBUTES)
      post('/v3/domains', attributes)
    end

    def delete_domain(name)
      delete("/v3/domains/#{escape name}")
    end

    def verify_domain(name)
      put("/v3/domains/#{escape name}/verify")
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

    def get_tracking_settings
      get("/v3/domains/#{escape @domain}/tracking")
    end

    def update_open_tracking_settings(params = PARAMS)
      put("/v3/domains/#{escape @domain}/tracking/open", params)
    end

    def update_click_tracking_settings(params = PARAMS)
      put("/v3/domains/#{escape @domain}/tracking/click", params)
    end

    def update_unsubscribe_tracking_settings(params = PARAMS)
      put("/v3/domains/#{escape @domain}/tracking/unsubscribe", params)
    end

    def update_dkim_authority(params = PARAMS)
      put("/v3/domains/#{escape @domain}/dkim_authority", params)
    end
  end
end
