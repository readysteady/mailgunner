# frozen_string_literal: true

module Mailgunner
  class Client
    def get_total_stats(params = {})
      get("/v3/#{escape @domain}/stats/total", query: params)
    end
  end
end
