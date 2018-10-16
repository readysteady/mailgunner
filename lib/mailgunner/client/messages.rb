# frozen_string_literal: true

module Mailgunner
  class Client
    def get_message(key)
      get("/v3/domains/#{escape @domain}/messages/#{escape key}")
    end

    def get_mime_message(key)
      get("/v3/domains/#{escape @domain}/messages/#{escape key}", {}, {'Accept' => 'message/rfc2822'})
    end

    def send_message(attributes = {})
      post("/v3/#{escape @domain}/messages", attributes)
    end

    def send_mime(mail)
      to = ['to', Array(mail.destinations).join(',')]

      message = ['message', mail.encoded, {filename: 'message.mime'}]

      multipart_post("/v3/#{escape @domain}/messages.mime", [to, message])
    end

    def delete_message(key)
      delete("/v3/domains/#{escape @domain}/messages/#{escape key}")
    end
  end
end
