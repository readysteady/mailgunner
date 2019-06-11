# frozen_string_literal: true

module Mailgunner
  class Client
    def get_events(params = PARAMS)
      get("/v3/#{escape @domain}/events", query: params)
    end
  end
end
