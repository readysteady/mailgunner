require 'minitest/autorun'
require 'mocha/setup'
require 'mailgunner'

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

  describe 'client_error query method' do
    it 'returns true if the status code is 4xx' do
      @http_response.stubs(:code).returns(%w(400 401 402 404).sample)

      @response.client_error?.must_equal(true)
    end

    it 'returns false otherwise' do
      @http_response.stubs(:code).returns('200')

      @response.client_error?.must_equal(false)
    end
  end

  describe 'server_error query method' do
    it 'returns true if the status code is 5xx' do
      @http_response.stubs(:code).returns(%w(500 502 503 504).sample)

      @response.server_error?.must_equal(true)
    end

    it 'returns false otherwise' do
      @http_response.stubs(:code).returns('200')

      @response.server_error?.must_equal(false)
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
