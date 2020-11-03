require 'spec_helper'

RSpec.describe Mailgunner::Error do
  describe '.parse' do
    it 'parses application/json messages' do
      error = Mailgunner::Error.parse(response(401, '{"message":"Unknown domain"}'))

      expect(error.message).to eq('Unknown domain')
    end

    it 'returns AuthenticationError for 401 responses' do
      error = Mailgunner::Error.parse(response(401))

      expect(error).to be_instance_of(Mailgunner::AuthenticationError)
    end

    it 'returns ClientError for 4xx responses' do
      error = Mailgunner::Error.parse(response(400))

      expect(error).to be_instance_of(Mailgunner::ClientError)
    end

    it 'returns ServerError for 5xx responses' do
      error = Mailgunner::Error.parse(response(500))

      expect(error).to be_instance_of(Mailgunner::ServerError)
    end

    it 'returns Error for other responses' do
      error = Mailgunner::Error.parse(response(100))

      expect(error).to be_instance_of(Mailgunner::Error)
    end
  end

  def response(code, body = nil)
    code = code.to_s

    response = Net::HTTPResponse::CODE_TO_OBJ[code].new(nil, code, nil)

    if body
      response['Content-Type'] = 'application/json'
      response.instance_variable_set(:@read, true)
      response.body = body
    end

    response
  end
end
