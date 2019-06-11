require 'minitest/autorun'
require 'mailgunner'

describe 'Mailgunner::Error' do
  describe 'parse method' do
    it 'parses application/json messages' do
      error = Mailgunner::Error.parse(response(401, '{"message":"Unknown domain"}'))
      error.message.must_equal('Unknown domain')
    end

    it 'returns AuthenticationError for 401 responses' do
      error = Mailgunner::Error.parse(response(401))
      error.must_be_instance_of(Mailgunner::AuthenticationError)
    end

    it 'returns ClientError for 4xx responses' do
      error = Mailgunner::Error.parse(response(400))
      error.must_be_instance_of(Mailgunner::ClientError)
    end

    it 'returns ServerError for 5xx responses' do
      error = Mailgunner::Error.parse(response(500))
      error.must_be_instance_of(Mailgunner::ServerError)
    end

    it 'returns Error for other responses' do
      error = Mailgunner::Error.parse(response(100))
      error.must_be_instance_of(Mailgunner::Error)
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
