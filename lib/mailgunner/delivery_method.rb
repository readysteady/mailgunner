require 'mail/check_delivery_params'

module Mailgunner
  class DeliveryFailed < StandardError
  end

  class DeliveryMethod
    include Mail::CheckDeliveryParams

    attr_accessor :settings

    def initialize(values)
      @settings = values

      @client = if @settings.has_key?(:domain)
        Client.new(domain: @settings[:domain])
      else
        Client.new
      end
    end

    def deliver!(mail)
      check_delivery_params(mail)

      response = @client.send_mime(mail)

      if response.ok?
        return response
      elsif response.json? && response.object.has_key?('message')
        raise DeliveryFailed, response.object['message']
      else
        raise DeliveryFailed, "#{response.code} #{response.message}"
      end
    end
  end

  ActionMailer::Base.add_delivery_method :mailgun, DeliveryMethod
end
