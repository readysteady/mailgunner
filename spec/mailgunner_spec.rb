require 'minitest/autorun'
require 'mailgunner'
require 'mocha'

class Net::HTTPGenericRequest
  def inspect
    if request_body_permitted?
      "<#{self.class.name} #{path} #{body}>"
    else
      "<#{self.class.name} #{path}>"
    end
  end
end

describe 'Mailgunner::Client' do
  before do
    @domain = 'samples.mailgun.org'

    @client = Mailgunner::Client.new(domain: @domain, api_key: 'xxx')
  end

  def expect(request_class, request_uri, *matchers)
    request = all_of(instance_of(request_class), responds_with(:path, request_uri), *matchers)

    @client.http.expects(:request).with(request).returns(stub)
  end

  describe 'http method' do
    it 'returns a net http object that uses ssl' do
      @client.http.must_be_instance_of(Net::HTTP)

      @client.http.use_ssl?.must_equal(true)
    end
  end

  describe 'get_unsubscribes method' do
    it 'fetches the domain unsubscribes resource and returns a response object' do
      expect(Net::HTTP::Get, "/v2/#@domain/unsubscribes")

      @client.get_unsubscribes.must_be_instance_of(Mailgunner::Response)
    end

    it 'encodes skip and limit parameters' do
      expect(Net::HTTP::Get, "/v2/#@domain/unsubscribes?skip=1&limit=2")

      @client.get_unsubscribes(skip: 1, limit: 2)
    end
  end

  describe 'get_unsubscribe method' do
    it 'fetches the unsubscribe resource with the given address and returns a response object' do
      expect(Net::HTTP::Get, "/v2/#@domain/unsubscribes/ev%40mailgun.net")

      @client.get_unsubscribe('ev@mailgun.net').must_be_instance_of(Mailgunner::Response)
    end
  end

  describe 'delete_unsubscribe method' do
    it 'deletes the domain unsubscribe resource with the given address and returns a response object' do
      expect(Net::HTTP::Delete, "/v2/#@domain/unsubscribes/ev%40mailgun.net")

      @client.delete_unsubscribe('ev@mailgun.net').must_be_instance_of(Mailgunner::Response)
    end
  end

  describe 'add_unsubscribe method' do
    it 'posts to the domain unsubscribes resource and returns a response object' do
      expect(Net::HTTP::Post, "/v2/#@domain/unsubscribes")

      @client.add_unsubscribe({}).must_be_instance_of(Mailgunner::Response)
    end

    it 'encodes the unsubscribe attributes' do
      expect(Net::HTTP::Post, "/v2/#@domain/unsubscribes", responds_with(:body, 'address=ev%40mailgun.net'))

      @client.add_unsubscribe({address: 'ev@mailgun.net'})
    end
  end

  describe 'get_complaints method' do
    it 'fetches the domain complaints resource and returns a response object' do
      expect(Net::HTTP::Get, "/v2/#@domain/complaints")

      @client.get_complaints.must_be_instance_of(Mailgunner::Response)
    end

    it 'encodes skip and limit parameters' do
      expect(Net::HTTP::Get, "/v2/#@domain/complaints?skip=1&limit=2")

      @client.get_complaints(skip: 1, limit: 2)
    end
  end

  describe 'get_complaint method' do
    it 'fetches the complaint resource with the given address and returns a response object' do
      expect(Net::HTTP::Get, "/v2/#@domain/complaints/romanto%40profista.com")

      @client.get_complaint('romanto@profista.com').must_be_instance_of(Mailgunner::Response)
    end
  end

  describe 'add_complaint method' do
    it 'posts to the domain complaints resource and returns a response object' do
      expect(Net::HTTP::Post, "/v2/#@domain/complaints")

      @client.add_complaint({}).must_be_instance_of(Mailgunner::Response)
    end

    it 'encodes the complaint attributes' do
      expect(Net::HTTP::Post, "/v2/#@domain/complaints", responds_with(:body, 'address=ev%40mailgun.net'))

      @client.add_complaint({address: 'ev@mailgun.net'})
    end
  end

  describe 'delete_complaint method' do
    it 'deletes the domain complaint resource with the given address and returns a response object' do
      expect(Net::HTTP::Delete, "/v2/#@domain/complaints/romanto%40profista.com")

      @client.delete_complaint('romanto@profista.com').must_be_instance_of(Mailgunner::Response)
    end
  end

  describe 'get_bounces method' do
    it 'fetches the domain bounces resource and returns a response object' do
      expect(Net::HTTP::Get, "/v2/#@domain/bounces")

      @client.get_bounces.must_be_instance_of(Mailgunner::Response)
    end

    it 'encodes skip and limit parameters' do
      expect(Net::HTTP::Get, "/v2/#@domain/bounces?skip=1&limit=2")

      @client.get_bounces(skip: 1, limit: 2)
    end
  end

  describe 'get_bounce method' do
    it 'fetches the bounce resource with the given address and returns a response object' do
      expect(Net::HTTP::Get, "/v2/#@domain/bounces/foo%40bar.com")

      @client.get_bounce('foo@bar.com').must_be_instance_of(Mailgunner::Response)
    end
  end

  describe 'add_bounce method' do
    it 'posts to the domain bounces resource and returns a response object' do
      expect(Net::HTTP::Post, "/v2/#@domain/bounces")

      @client.add_bounce({}).must_be_instance_of(Mailgunner::Response)
    end

    it 'encodes the bounce attributes' do
      expect(Net::HTTP::Post, "/v2/#@domain/bounces", responds_with(:body, 'address=ev%40mailgun.net'))

      @client.add_bounce({address: 'ev@mailgun.net'})
    end
  end

  describe 'delete_bounce method' do
    it 'deletes the domain bounce resource with the given address and returns a response object' do
      expect(Net::HTTP::Delete, "/v2/#@domain/bounces/ev%40mailgun.net")

      @client.delete_bounce('ev@mailgun.net').must_be_instance_of(Mailgunner::Response)
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

  describe 'get_routes method' do
    it 'fetches the global routes resource and returns a response object' do
      expect(Net::HTTP::Get, '/v2/routes')

      @client.get_routes.must_be_instance_of(Mailgunner::Response)
    end

    it 'encodes skip and limit parameters' do
      expect(Net::HTTP::Get, '/v2/routes?skip=1&limit=2')

      @client.get_routes(skip: 1, limit: 2)
    end
  end

  describe 'get_route method' do
    it 'fetches the route resource with the given id and returns a response object' do
      expect(Net::HTTP::Get, '/v2/routes/4f3bad2335335426750048c6')

      @client.get_route('4f3bad2335335426750048c6').must_be_instance_of(Mailgunner::Response)
    end
  end

  describe 'add_route method' do
    it 'posts to the routes resource and returns a response object' do
      expect(Net::HTTP::Post, '/v2/routes')

      @client.add_route({}).must_be_instance_of(Mailgunner::Response)
    end

    it 'encodes the route attributes' do
      expect(Net::HTTP::Post, '/v2/routes', responds_with(:body, 'description=Example+route&priority=1'))

      @client.add_route({description: 'Example route', priority: 1})
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
