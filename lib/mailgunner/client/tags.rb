# frozen_string_literal: true

module Mailgunner
  class Client
    def get_tags(params = {})
      get("/v3/#{escape @domain}/tags", params)
    end

    def get_tag(id)
      get("/v3/#{escape @domain}/tags/#{escape id}")
    end

    def update_tag(id, attributes)
      put("/v3/#{escape @domain}/tags/#{escape id}", attributes)
    end

    def get_tag_stats(id, params)
      get("/v3/#{escape @domain}/tags/#{escape id}/stats", params)
    end

    def delete_tag(id)
      delete("/v3/#{escape @domain}/tags/#{escape id}")
    end
  end
end
