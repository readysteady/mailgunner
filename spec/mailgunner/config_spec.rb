require 'spec_helper'

RSpec.describe Mailgunner::Config do
  let(:config) { Mailgunner::Config.new }

  describe '#domain' do
    it 'returns a default value' do
      ENV['MAILGUN_SMTP_LOGIN'] = 'postmaster@samples.mailgun.org'

      expect(config.domain).to eq('samples.mailgun.org')

      ENV.delete('MAILGUN_SMTP_LOGIN')
    end
  end

  describe '#api_key' do
    let(:api_key) { 'api_key_xxx' }

    it 'returns a default value' do
      ENV['MAILGUN_API_KEY'] = api_key

      expect(config.api_key).to eq(api_key)

      ENV.delete('MAILGUN_API_KEY')
    end
  end

  describe '#api_host' do
    it 'returns a default value' do
      expect(config.api_host).to eq('api.mailgun.net')
    end
  end

  describe '#user_agent' do
    it 'returns a default value' do
      expect(config.user_agent).to match(/\ARuby\/\d+\.\d+\.\d+ Mailgunner\/\d+\.\d+\.\d+\z/)
    end
  end
end
