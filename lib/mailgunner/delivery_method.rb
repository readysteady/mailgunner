require 'mail/check_delivery_params'

module Mailgunner
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

      @client.send_mime(mail)
    end
  end

  ActionMailer::Base.add_delivery_method :mailgun, DeliveryMethod
end
