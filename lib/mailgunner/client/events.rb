# frozen_string_literal: true

module Mailgunner
  class Client
    def get_events(params = {})
      get("/v3/#{escape @domain}/events", params)
    end
  end
end
