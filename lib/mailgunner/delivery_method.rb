require 'mail/check_delivery_params'

module Mailgunner
  class DeliveryMethod
    include Mail::CheckDeliveryParams

    attr_accessor :settings

    def initialize(values)
      @client = Client.new(values)
    end

    def deliver!(mail)
      check_delivery_params(mail)

      @client.send_mime(mail)
    end
  end

  ActionMailer::Base.add_delivery_method :mailgun, DeliveryMethod
end
