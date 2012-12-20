require 'minitest/autorun'
require 'mailgunner'
require 'mocha'

class Net::HTTPGenericRequest
  def inspect
    "<#{self.class.name} #{path}>"
  end
end

describe 'Mailgunner::Client' do
  before do
    @domain = 'samples.mailgun.org'

    @client = Mailgunner::Client.new(domain: @domain, api_key: 'xxx')
  end

  def expect(request_class, request_uri)
    request = all_of(instance_of(request_class), responds_with(:path, request_uri))

    @client.http.expects(:request).with(request).returns(stub)
  end

  describe 'http method' do
    it 'returns a net http object that uses ssl' do
      @client.http.must_be_instance_of(Net::HTTP)

      @client.http.use_ssl?.must_equal(true)
    end
  end

  describe 'get_stats method' do
    it 'fetches the domain stats resource and returns a response object' do
      expect(Net::HTTP::Get, "/v2/#@domain/stats")

      @client.get_stats.must_be_instance_of(Mailgunner::Response)
    end

    it 'encodes skip and limit parameters' do
      expect(Net::HTTP::Get, "/v2/#@domain/stats?skip=1&limit=2")

      @client.get_stats(skip: 1, limit: 2)
    end

    it 'encodes an event parameter with multiple values' do
      expect(Net::HTTP::Get, "/v2/#@domain/stats?event=sent&event=opened")

      @client.get_stats(event: %w(sent opened))
    end
  end

  describe 'get_log method' do
    it 'fetches the domain stats resource and returns a response object' do
      expect(Net::HTTP::Get, "/v2/#@domain/log")

      @client.get_log.must_be_instance_of(Mailgunner::Response)
    end

    it 'encodes skip and limit parameters' do
      expect(Net::HTTP::Get, "/v2/#@domain/log?skip=1&limit=2")

      @client.get_log(skip: 1, limit: 2)
    end
  end
end

describe 'Mailgunner::Response' do
  before do
    @http_response = mock()

    @response = Mailgunner::Response.new(@http_response)
  end

  it 'delegates missing methods to the http response object' do
    @http_response.stubs(:code).returns('200')

    @response.code.must_equal('200')
  end

  describe 'ok query method' do
    it 'returns true if the status code is 200' do
      @http_response.expects(:code).returns('200')

      @response.ok?.must_equal(true)
    end

    it 'returns false otherwise' do
      @http_response.expects(:code).returns('400')

      @response.ok?.must_equal(false)
    end
  end

  describe 'json query method' do
    it 'returns true if the response has a json content type' do
      @http_response.expects(:[]).with('Content-Type').returns('application/json;charset=utf-8')

      @response.json?.must_equal(true)
    end

    it 'returns false otherwise' do
      @http_response.expects(:[]).with('Content-Type').returns('text/html')

      @response.json?.must_equal(false)
    end
  end

  describe 'object method' do
    it 'decodes the response body as json and returns a hash' do
      @http_response.expects(:body).returns('{"foo":"bar"}')

      @response.object.must_equal({'foo' => 'bar'})
    end
  end
end
