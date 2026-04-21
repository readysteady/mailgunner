require 'mail/smtp_envelope'

module Mailgunner
  class DeliveryMethod
    attr_accessor :settings

    def initialize(values)
      self.settings = values
    end

    def deliver!(mail)
      envelope = Mail::SmtpEnvelope.new(mail)

      client = Client.new(**settings)
      client.send_mime(mail)
    end
  end

  if defined?(ActionMailer)
    ActionMailer::Base.add_delivery_method :mailgun, DeliveryMethod
  end
end
