begin
  require 'mail/smtp_envelope'
rescue LoadError
  require 'mail/check_delivery_params'
end

module Mailgunner
  class DeliveryMethod
    attr_accessor :settings

    def initialize(values)
      self.settings = values
    end

    def deliver!(mail)
      check(mail)

      client = Client.new(**settings)
      client.send_mime(mail)
    end

    private

    if defined?(Mail::SmtpEnvelope) # mail v2.8.0+
      def check(mail)
        Mail::SmtpEnvelope.new(mail)
      end
    elsif Mail::CheckDeliveryParams.respond_to?(:check) # mail v2.6.6+
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
