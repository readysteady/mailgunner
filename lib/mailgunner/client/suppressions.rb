# frozen_string_literal: true

module Mailgunner
  class Client
    def get_bounces(params = PARAMS)
      get("/v3/#{escape @domain}/bounces", query: params)
    end

    def get_bounce(address)
      get("/v3/#{escape @domain}/bounces/#{escape address}")
    end

    def add_bounce(attributes = ATTRIBUTES)
      post("/v3/#{escape @domain}/bounces", attributes)
    end

    def delete_bounce(address)
      delete("/v3/#{escape @domain}/bounces/#{escape address}")
    end

    def delete_bounces
      delete("/v3/#{escape @domain}/bounces")
    end

    def get_unsubscribes(params = PARAMS)
      get("/v3/#{escape @domain}/unsubscribes", query: params)
    end

    def get_unsubscribe(address)
      get("/v3/#{escape @domain}/unsubscribes/#{escape address}")
    end

    def delete_unsubscribe(address_or_id)
      delete("/v3/#{escape @domain}/unsubscribes/#{escape address_or_id}")
    end

    def add_unsubscribe(attributes = ATTRIBUTES)
      post("/v3/#{escape @domain}/unsubscribes", attributes)
    end

    def get_complaints(params = PARAMS)
      get("/v3/#{escape @domain}/complaints", query: params)
    end

    def get_complaint(address)
      get("/v3/#{escape @domain}/complaints/#{escape address}")
    end

    def add_complaint(attributes = ATTRIBUTES)
      post("/v3/#{escape @domain}/complaints", attributes)
    end

    def delete_complaint(address)
      delete("/v3/#{escape @domain}/complaints/#{escape address}")
    end
  end
end
