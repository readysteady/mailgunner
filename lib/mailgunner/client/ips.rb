# frozen_string_literal: true

module Mailgunner
  class Client
    def get_all_ips(params = {})
      get('/v3/ips', params)
    end

    def get_ip(address)
      get("/v3/ips/#{escape address}")
    end

    def get_ips
      get("/v3/domains/#{escape @domain}/ips")
    end

    def add_ip(address)
      post("/v3/domains/#{escape @domain}/ips", ip: address)
    end

    def delete_ip(address)
      delete("/v3/domains/#{escape @domain}/ips/#{escape address}")
    end
  end
end
