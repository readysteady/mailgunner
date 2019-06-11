# frozen_string_literal: true

module Mailgunner
  class Config
    def domain
      @domain ||= default_domain
    end

    attr_writer :domain

    def api_key
      @api_key ||= ENV.fetch('MAILGUN_API_KEY')
    end

    attr_writer :api_key

    def api_host
      @api_host ||= 'api.mailgun.net'
    end

    attr_writer :api_host

    def user_agent
      @user_agent ||= "Ruby/#{RUBY_VERSION} Mailgunner/#{VERSION}"
    end

    attr_writer :user_agent

    module NoDomainProvided
      def self.to_s
        raise Error, 'No domain provided'
      end
    end

    private_constant :NoDomainProvided

    private

    def default_domain
      return NoDomainProvided unless ENV.key?('MAILGUN_SMTP_LOGIN')

      ENV['MAILGUN_SMTP_LOGIN'].to_s.split('@').last
    end
  end
end
