require 'minitest/global_expectations/autorun'
require 'mailgunner'

describe 'Mailgunner::Config' do
  let(:config) { Mailgunner::Config.new }
  let(:api_key) { 'api_key_xxx' }

  describe 'domain method' do
    it 'returns a default value' do
      ENV['MAILGUN_SMTP_LOGIN'] = 'postmaster@samples.mailgun.org'

      config.domain.must_equal('samples.mailgun.org')

      ENV.delete('MAILGUN_SMTP_LOGIN')
    end
  end

  describe 'api_key method' do
    it 'returns a default value' do
      ENV['MAILGUN_API_KEY'] = api_key

      config.api_key.must_equal(api_key)

      ENV.delete('MAILGUN_API_KEY')
    end
  end

  describe 'api_host method' do
    it 'returns a default value' do
      config.api_host.must_equal('api.mailgun.net')
    end
  end

  describe 'user_agent method' do
    it 'returns a default value' do
      config.user_agent.must_match(/\ARuby\/\d+\.\d+\.\d+ Mailgunner\/\d+\.\d+\.\d+\z/)
    end
  end
end
