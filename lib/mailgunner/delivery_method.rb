require 'mail/check_delivery_params'

module Mailgunner
  class DeliveryMethod
    attr_accessor :settings

    def initialize(values)
      @client = Client.new(values)
    end

    def deliver!(mail)
      check(mail)

      @client.send_mime(mail)
    end

    private

    if Mail::CheckDeliveryParams.respond_to?(:check) # mail v2.6.6+
      def check(mail)
        Mail::CheckDeliveryParams.check(mail)
      end
    else
      include Mail::CheckDeliveryParams

      def check(mail)
        check_delivery_params(mail)
      end
    end
  end

  if defined?(ActionMailer)
    ActionMailer::Base.add_delivery_method :mailgun, DeliveryMethod
  end
end
