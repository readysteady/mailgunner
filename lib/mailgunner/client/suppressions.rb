# frozen_string_literal: true

module Mailgunner
  class Client
    def get_bounces(params = {})
      get("/v3/#{escape @domain}/bounces", params)
    end

    def get_bounce(address)
      get("/v3/#{escape @domain}/bounces/#{escape address}")
    end

    def add_bounce(attributes = {})
      post("/v3/#{escape @domain}/bounces", attributes)
    end

    def delete_bounce(address)
      delete("/v3/#{escape @domain}/bounces/#{escape address}")
    end

    def delete_bounces
      delete("/v3/#{escape @domain}/bounces")
    end

    def get_unsubscribes(params = {})
      get("/v3/#{escape @domain}/unsubscribes", params)
    end

    def get_unsubscribe(address)
      get("/v3/#{escape @domain}/unsubscribes/#{escape address}")
    end

    def delete_unsubscribe(address_or_id)
      delete("/v3/#{escape @domain}/unsubscribes/#{escape address_or_id}")
    end

    def add_unsubscribe(attributes = {})
      post("/v3/#{escape @domain}/unsubscribes", attributes)
    end

    def get_complaints(params = {})
      get("/v3/#{escape @domain}/complaints", params)
    end

    def get_complaint(address)
      get("/v3/#{escape @domain}/complaints/#{escape address}")
    end

    def add_complaint(attributes = {})
      post("/v3/#{escape @domain}/complaints", attributes)
    end

    def delete_complaint(address)
      delete("/v3/#{escape @domain}/complaints/#{escape address}")
    end
  end
end
