require 'mailgunner/version'
require 'mailgunner/errors'
require 'mailgunner/params'
require 'mailgunner/config'
require 'mailgunner/struct'
require 'mailgunner/client'
require 'mailgunner/client/domains'
require 'mailgunner/client/email_validation'
require 'mailgunner/client/events'
require 'mailgunner/client/ips'
require 'mailgunner/client/mailing_lists'
require 'mailgunner/client/messages'
require 'mailgunner/client/routes'
require 'mailgunner/client/stats'
require 'mailgunner/client/suppressions'
require 'mailgunner/client/tags'
require 'mailgunner/client/webhooks'
require 'mailgunner/delivery_method' if defined?(Mail)
require 'mailgunner/railtie' if defined?(Rails)

module Mailgunner
  def self.config
    @config ||= Config.new
  end

  def self.configure
    yield config
  end
end
