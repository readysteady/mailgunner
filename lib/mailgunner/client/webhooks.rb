# frozen_string_literal: true

module Mailgunner
  class Client
    def get_webhooks
      get("/v3/domains/#{escape @domain}/webhooks")
    end

    def get_webhook(id)
      get("/v3/domains/#{escape @domain}/webhooks/#{escape id}")
    end

    def add_webhook(attributes = {})
      post("/v3/domains/#{escape @domain}/webhooks", attributes)
    end

    def update_webhook(id, attributes = {})
      put("/v3/domains/#{escape @domain}/webhooks/#{escape id}", attributes)
    end

    def delete_webhook(id)
      delete("/v3/domains/#{escape @domain}/webhooks/#{escape id}")
    end
  end
end
