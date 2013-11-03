require 'minitest/autorun'
require 'webmock/minitest'
require 'mocha/setup'
require 'mailgunner'
require 'json'
require 'mail'

describe 'Mailgunner::Client' do
  before do
    @domain = 'samples.mailgun.org'

    @api_key = 'xxx'

    @base_url = "https://api:#{@api_key}@api.mailgun.net/v2"

    @client = Mailgunner::Client.new(domain: @domain, api_key: @api_key)

    @address = 'user@example.com'

    @encoded_address = 'user%40example.com'
  end

  describe 'http method' do
    it 'returns a net http object that uses ssl' do
      @client.http.must_be_instance_of(Net::HTTP)

      @client.http.use_ssl?.must_equal(true)
    end
  end

  describe 'domain method' do
    it 'returns the value passed to the constructor' do
      @client.domain.must_equal(@domain)
    end

    it 'defaults to the domain in the MAILGUN_SMTP_LOGIN environment variable' do
      ENV['MAILGUN_SMTP_LOGIN'] = 'postmaster@samples.mailgun.org'

      Mailgunner::Client.new(api_key: @api_key).domain.must_equal(@domain)
    end

    it 'defaults to nil if the MAILGUN_SMTP_LOGIN environment variable does not exist' do
      ENV.delete('MAILGUN_SMTP_LOGIN')

      Mailgunner::Client.new(api_key: @api_key).domain.must_be_nil
    end
  end

  describe 'api_key method' do
    it 'returns the value passed to the constructor' do
      @client.api_key.must_equal(@api_key)
    end

    it 'defaults to the value of MAILGUN_API_KEY environment variable' do
      ENV['MAILGUN_API_KEY'] = @api_key

      Mailgunner::Client.new(domain: @domain).api_key.must_equal(@api_key)
    end
  end

  describe 'validate_address method' do
    it 'calls the address validate resource with the given email address and returns a response object' do
      stub_request(:get, "#@base_url/address/validate?address=#@encoded_address")

      @client.validate_address(@address).must_be_instance_of(Mailgunner::Response)
    end
  end

  describe 'parse_addresses method' do
    it 'calls the address parse resource with the given email addresses and returns a response object' do
      stub_request(:get, "#@base_url/address/parse?addresses=bob%40example.com%2Ceve%40example.com")

      @client.parse_addresses(['bob@example.com', 'eve@example.com']).must_be_instance_of(Mailgunner::Response)
    end
  end

  describe 'send_message method' do
    it 'posts to the domain messages resource and returns a response object' do
      stub_request(:post, "#@base_url/#@domain/messages")

      @client.send_message({}).must_be_instance_of(Mailgunner::Response)
    end

    it 'encodes the message attributes' do
      stub_request(:post, "#@base_url/#@domain/messages").with(body: "to=#@encoded_address")

      @client.send_message({to: @address})
    end

    it 'encodes the message attributes as multipart form data when sending attachments' do
      # TODO
    end
  end

  describe 'send_mime method' do
    before do
      @mail = Mail.new({
        to: 'alice@example.com',
        from: 'bob@example.com',
        subject: 'Test email',
        body: 'This is a test email'
      })
    end

    it 'posts to the domain messages resource and returns a response object' do
      stub_request(:post, "#@base_url/#@domain/messages.mime")

      @client.send_mime(@mail).must_be_instance_of(Mailgunner::Response)
    end
  end

  describe 'get_domains method' do
    it 'fetches the domains resource and returns a response object' do
      stub_request(:get, "#@base_url/domains")

      @client.get_domains.must_be_instance_of(Mailgunner::Response)
    end
  end

  describe 'get_domain method' do
    it 'fetches the domain resource and returns a response object' do
      stub_request(:get, "#@base_url/domains/#@domain")

      @client.get_domain(@domain).must_be_instance_of(Mailgunner::Response)
    end
  end

  describe 'add_domain method' do
    it 'posts to the domains resource and returns a response object' do
      stub_request(:post, "#@base_url/domains")

      @client.add_domain({}).must_be_instance_of(Mailgunner::Response)
    end

    it 'encodes the domain attributes' do
      stub_request(:post, "#@base_url/domains").with(body: "name=#@domain")

      @client.add_domain({name: @domain})
    end
  end

  describe 'get_unsubscribes method' do
    it 'fetches the domain unsubscribes resource and returns a response object' do
      stub_request(:get, "#@base_url/#@domain/unsubscribes")

      @client.get_unsubscribes.must_be_instance_of(Mailgunner::Response)
    end

    it 'encodes skip and limit parameters' do
      stub_request(:get, "#@base_url/#@domain/unsubscribes?skip=1&limit=2")

      @client.get_unsubscribes(skip: 1, limit: 2)
    end
  end

  describe 'get_unsubscribe method' do
    it 'fetches the unsubscribe resource with the given address and returns a response object' do
      stub_request(:get, "#@base_url/#@domain/unsubscribes/#@encoded_address")

      @client.get_unsubscribe(@address).must_be_instance_of(Mailgunner::Response)
    end
  end

  describe 'delete_unsubscribe method' do
    it 'deletes the domain unsubscribe resource with the given address and returns a response object' do
      stub_request(:delete, "#@base_url/#@domain/unsubscribes/#@encoded_address")

      @client.delete_unsubscribe(@address).must_be_instance_of(Mailgunner::Response)
    end
  end

  describe 'add_unsubscribe method' do
    it 'posts to the domain unsubscribes resource and returns a response object' do
      stub_request(:post, "#@base_url/#@domain/unsubscribes")

      @client.add_unsubscribe({}).must_be_instance_of(Mailgunner::Response)
    end

    it 'encodes the unsubscribe attributes' do
      stub_request(:post, "#@base_url/#@domain/unsubscribes").with(body: "address=#@encoded_address")

      @client.add_unsubscribe({address: @address})
    end
  end

  describe 'get_complaints method' do
    it 'fetches the domain complaints resource and returns a response object' do
      stub_request(:get, "#@base_url/#@domain/complaints")

      @client.get_complaints.must_be_instance_of(Mailgunner::Response)
    end

    it 'encodes skip and limit parameters' do
      stub_request(:get, "#@base_url/#@domain/complaints?skip=1&limit=2")

      @client.get_complaints(skip: 1, limit: 2)
    end
  end

  describe 'get_complaint method' do
    it 'fetches the complaint resource with the given address and returns a response object' do
      stub_request(:get, "#@base_url/#@domain/complaints/#@encoded_address")

      @client.get_complaint(@address).must_be_instance_of(Mailgunner::Response)
    end
  end

  describe 'add_complaint method' do
    it 'posts to the domain complaints resource and returns a response object' do
      stub_request(:post, "#@base_url/#@domain/complaints")

      @client.add_complaint({}).must_be_instance_of(Mailgunner::Response)
    end

    it 'encodes the complaint attributes' do
      stub_request(:post, "#@base_url/#@domain/complaints").with(body: "address=#@encoded_address")

      @client.add_complaint({address: @address})
    end
  end

  describe 'delete_complaint method' do
    it 'deletes the domain complaint resource with the given address and returns a response object' do
      stub_request(:delete, "#@base_url/#@domain/complaints/#@encoded_address")

      @client.delete_complaint(@address).must_be_instance_of(Mailgunner::Response)
    end
  end

  describe 'get_bounces method' do
    it 'fetches the domain bounces resource and returns a response object' do
      stub_request(:get, "#@base_url/#@domain/bounces")

      @client.get_bounces.must_be_instance_of(Mailgunner::Response)
    end

    it 'encodes skip and limit parameters' do
      stub_request(:get, "#@base_url/#@domain/bounces?skip=1&limit=2")

      @client.get_bounces(skip: 1, limit: 2)
    end
  end

  describe 'get_bounce method' do
    it 'fetches the bounce resource with the given address and returns a response object' do
      stub_request(:get, "#@base_url/#@domain/bounces/#@encoded_address")

      @client.get_bounce(@address).must_be_instance_of(Mailgunner::Response)
    end
  end

  describe 'add_bounce method' do
    it 'posts to the domain bounces resource and returns a response object' do
      stub_request(:post, "#@base_url/#@domain/bounces")

      @client.add_bounce({}).must_be_instance_of(Mailgunner::Response)
    end

    it 'encodes the bounce attributes' do
      stub_request(:post, "#@base_url/#@domain/bounces").with(body: "address=#@encoded_address")

      @client.add_bounce({address: @address})
    end
  end

  describe 'delete_bounce method' do
    it 'deletes the domain bounce resource with the given address and returns a response object' do
      stub_request(:delete, "#@base_url/#@domain/bounces/#@encoded_address")

      @client.delete_bounce(@address).must_be_instance_of(Mailgunner::Response)
    end
  end

  describe 'get_stats method' do
    it 'fetches the domain stats resource and returns a response object' do
      stub_request(:get, "#@base_url/#@domain/stats")

      @client.get_stats.must_be_instance_of(Mailgunner::Response)
    end

    it 'encodes skip and limit parameters' do
      stub_request(:get, "#@base_url/#@domain/stats?skip=1&limit=2")

      @client.get_stats(skip: 1, limit: 2)
    end

    it 'encodes an event parameter with multiple values' do
      stub_request(:get, "#@base_url/#@domain/stats?event=sent&event=opened")

      @client.get_stats(event: %w(sent opened))
    end
  end

  describe 'get_events method' do
    it 'fetches the domain events resource and returns a response object' do
      stub_request(:get, "#@base_url/#@domain/events")

      @client.get_events.must_be_instance_of(Mailgunner::Response)
    end

    it 'encodes optional parameters' do
      stub_request(:get, "#@base_url/#@domain/events?event=accepted&limit=10")

      @client.get_events(event: 'accepted', limit: 10)
    end
  end

  describe 'get_routes method' do
    it 'fetches the routes resource and returns a response object' do
      stub_request(:get, "#@base_url/routes")

      @client.get_routes.must_be_instance_of(Mailgunner::Response)
    end

    it 'encodes skip and limit parameters' do
      stub_request(:get, "#@base_url/routes?skip=1&limit=2")

      @client.get_routes(skip: 1, limit: 2)
    end
  end

  describe 'get_route method' do
    it 'fetches the route resource with the given id and returns a response object' do
      stub_request(:get, "#@base_url/routes/4f3bad2335335426750048c6")

      @client.get_route('4f3bad2335335426750048c6').must_be_instance_of(Mailgunner::Response)
    end
  end

  describe 'add_route method' do
    it 'posts to the routes resource and returns a response object' do
      stub_request(:post, "#@base_url/routes")

      @client.add_route({}).must_be_instance_of(Mailgunner::Response)
    end

    it 'encodes the route attributes' do
      stub_request(:post, "#@base_url/routes").with(body: 'description=Example+route&priority=1')

      @client.add_route({description: 'Example route', priority: 1})
    end
  end

  describe 'update_route method' do
    it 'updates the route resource with the given id and returns a response object' do
      stub_request(:put, "#@base_url/routes/4f3bad2335335426750048c6")

      @client.update_route('4f3bad2335335426750048c6', {}).must_be_instance_of(Mailgunner::Response)
    end

    it 'encodes the route attributes' do
      stub_request(:put, "#@base_url/routes/4f3bad2335335426750048c6").with(body: 'priority=10')

      @client.update_route('4f3bad2335335426750048c6', {priority: 10})
    end
  end

  describe 'delete_route method' do
    it 'deletes the route resource with the given id and returns a response object' do
      stub_request(:delete, "#@base_url/routes/4f3bad2335335426750048c6")

      @client.delete_route('4f3bad2335335426750048c6').must_be_instance_of(Mailgunner::Response)
    end
  end

  describe 'get_campaigns method' do
    it 'fetches the domain campaigns resource and returns a response object' do
      stub_request(:get, "#@base_url/#@domain/campaigns")

      @client.get_campaigns.must_be_instance_of(Mailgunner::Response)
    end

    it 'encodes skip and limit parameters' do
      stub_request(:get, "#@base_url/#@domain/campaigns?skip=1&limit=2")

      @client.get_campaigns(skip: 1, limit: 2)
    end
  end

  describe 'get_campaign method' do
    it 'fetches the campaign resource with the given id and returns a response object' do
      stub_request(:get, "#@base_url/#@domain/campaigns/id")

      @client.get_campaign('id').must_be_instance_of(Mailgunner::Response)
    end
  end

  describe 'add_campaign method' do
    it 'posts to the domain campaigns resource and returns a response object' do
      stub_request(:post, "#@base_url/#@domain/campaigns")

      @client.add_campaign({}).must_be_instance_of(Mailgunner::Response)
    end

    it 'encodes the campaign attributes' do
      stub_request(:post, "#@base_url/#@domain/campaigns").with(body: 'id=id')

      @client.add_campaign({id: 'id'})
    end
  end

  describe 'update_campaign method' do
    it 'updates the campaign resource and returns a response object' do
      stub_request(:put, "#@base_url/#@domain/campaigns/id")

      @client.update_campaign('id', {}).must_be_instance_of(Mailgunner::Response)
    end

    it 'encodes the campaign attributes' do
      stub_request(:put, "#@base_url/#@domain/campaigns/id").with(body: 'name=Example+Campaign')

      @client.update_campaign('id', {name: 'Example Campaign'})
    end
  end

  describe 'delete_campaign method' do
    it 'deletes the domain campaign resource with the given id and returns a response object' do
      stub_request(:delete, "#@base_url/#@domain/campaigns/id")

      @client.delete_campaign('id').must_be_instance_of(Mailgunner::Response)
    end
  end

  describe 'get_campaign_events method' do
    it 'fetches the domain campaign events resource and returns a response object' do
      stub_request(:get, "#@base_url/#@domain/campaigns/id/events")

      @client.get_campaign_events('id').must_be_instance_of(Mailgunner::Response)
    end

    it 'encodes the optional parameters' do
      stub_request(:get, "#@base_url/#@domain/campaigns/id/events?country=US&limit=100")

      @client.get_campaign_events('id', country: 'US', limit: 100)
    end
  end

  describe 'get_campaign_stats method' do
    it 'fetches the domain campaign stats resource and returns a response object' do
      stub_request(:get, "#@base_url/#@domain/campaigns/id/stats")

      @client.get_campaign_stats('id').must_be_instance_of(Mailgunner::Response)
    end

    it 'encodes the optional parameters' do
      stub_request(:get, "#@base_url/#@domain/campaigns/id/stats?groupby=dailyhour")

      @client.get_campaign_stats('id', groupby: 'dailyhour')
    end
  end

  describe 'get_campaign_clicks method' do
    it 'fetches the domain campaign clicks resource and returns a response object' do
      stub_request(:get, "#@base_url/#@domain/campaigns/id/clicks")

      @client.get_campaign_clicks('id').must_be_instance_of(Mailgunner::Response)
    end

    it 'encodes the optional parameters' do
      stub_request(:get, "#@base_url/#@domain/campaigns/id/clicks?groupby=month&limit=100")

      @client.get_campaign_clicks('id', groupby: 'month', limit: 100)
    end
  end

  describe 'get_campaign_opens method' do
    it 'fetches the domain campaign opens resource and returns a response object' do
      stub_request(:get, "#@base_url/#@domain/campaigns/id/opens")

      @client.get_campaign_opens('id').must_be_instance_of(Mailgunner::Response)
    end

    it 'encodes the optional parameters' do
      stub_request(:get, "#@base_url/#@domain/campaigns/id/opens?groupby=month&limit=100")

      @client.get_campaign_opens('id', groupby: 'month', limit: 100)
    end
  end

  describe 'get_campaign_unsubscribes method' do
    it 'fetches the domain campaign unsubscribes resource and returns a response object' do
      stub_request(:get, "#@base_url/#@domain/campaigns/id/unsubscribes")

      @client.get_campaign_unsubscribes('id').must_be_instance_of(Mailgunner::Response)
    end

    it 'encodes the optional parameters' do
      stub_request(:get, "#@base_url/#@domain/campaigns/id/unsubscribes?groupby=month&limit=100")

      @client.get_campaign_unsubscribes('id', groupby: 'month', limit: 100)
    end
  end

  describe 'get_campaign_complaints method' do
    it 'fetches the domain campaign complaints resource and returns a response object' do
      stub_request(:get, "#@base_url/#@domain/campaigns/id/complaints")

      @client.get_campaign_complaints('id').must_be_instance_of(Mailgunner::Response)
    end

    it 'encodes the optional parameters' do
      stub_request(:get, "#@base_url/#@domain/campaigns/id/complaints?groupby=month&limit=100")

      @client.get_campaign_complaints('id', groupby: 'month', limit: 100)
    end
  end

  describe 'get_lists method' do
    it 'fetches the lists resource and returns a response object' do
      stub_request(:get, "#@base_url/lists")

      @client.get_lists.must_be_instance_of(Mailgunner::Response)
    end

    it 'encodes skip and limit parameters' do
      stub_request(:get, "#@base_url/lists?skip=1&limit=2")

      @client.get_lists(skip: 1, limit: 2)
    end
  end

  describe 'get_list method' do
    it 'fetches the list resource with the given address and returns a response object' do
      stub_request(:get, "#@base_url/lists/developers%40mailgun.net")

      @client.get_list('developers@mailgun.net').must_be_instance_of(Mailgunner::Response)
    end
  end

  describe 'add_list method' do
    it 'posts to the lists resource and returns a response object' do
      stub_request(:post, "#@base_url/lists")

      @client.add_list({}).must_be_instance_of(Mailgunner::Response)
    end

    it 'encodes the list attributes' do
      stub_request(:post, "#@base_url/lists").with(body: 'address=developers%40mailgun.net')

      @client.add_list({address: 'developers@mailgun.net'})
    end
  end

  describe 'update_list method' do
    it 'updates the list resource and returns a response object' do
      stub_request(:put, "#@base_url/lists/developers%40mailgun.net")

      @client.update_list('developers@mailgun.net', {}).must_be_instance_of(Mailgunner::Response)
    end

    it 'encodes the list attributes' do
      stub_request(:put, "#@base_url/lists/developers%40mailgun.net").with(body: 'name=Example+list')

      @client.update_list('developers@mailgun.net', {name: 'Example list'})
    end
  end

  describe 'delete_list method' do
    it 'deletes the list resource with the given address and returns a response object' do
      stub_request(:delete, "#@base_url/lists/developers%40mailgun.net")

      @client.delete_list('developers@mailgun.net').must_be_instance_of(Mailgunner::Response)
    end
  end

  describe 'get_list_members method' do
    it 'fetches the list members resource and returns a response object' do
      stub_request(:get, "#@base_url/lists/developers%40mailgun.net/members")

      @client.get_list_members('developers@mailgun.net').must_be_instance_of(Mailgunner::Response)
    end

    it 'encodes skip and limit parameters' do
      stub_request(:get, "#@base_url/lists/developers%40mailgun.net/members?skip=1&limit=2")

      @client.get_list_members('developers@mailgun.net', skip: 1, limit: 2)
    end
  end

  describe 'get_list_member method' do
    it 'fetches the list member resource with the given address and returns a response object' do
      stub_request(:get, "#@base_url/lists/developers%40mailgun.net/members/#@encoded_address")

      @client.get_list_member('developers@mailgun.net', @address).must_be_instance_of(Mailgunner::Response)
    end
  end

  describe 'add_list_member method' do
    it 'posts to the list members resource and returns a response object' do
      stub_request(:post, "#@base_url/lists/developers%40mailgun.net/members")

      @client.add_list_member('developers@mailgun.net', {}).must_be_instance_of(Mailgunner::Response)
    end

    it 'encodes the list attributes' do
      stub_request(:post, "#@base_url/lists/developers%40mailgun.net/members").with(body: "address=#@encoded_address")

      @client.add_list_member('developers@mailgun.net', {address: @address})
    end
  end

  describe 'update_list_member method' do
    it 'updates the list member resource with the given address and returns a response object' do
      stub_request(:put, "#@base_url/lists/developers%40mailgun.net/members/#@encoded_address")

      @client.update_list_member('developers@mailgun.net', @address, {}).must_be_instance_of(Mailgunner::Response)
    end

    it 'encodes the list member attributes' do
      stub_request(:put, "#@base_url/lists/developers%40mailgun.net/members/#@encoded_address").with(body: 'subscribed=no')

      @client.update_list_member('developers@mailgun.net', @address, {subscribed: 'no'})
    end
  end

  describe 'delete_list_member method' do
    it 'deletes the list member resource with the given address and returns a response object' do
      stub_request(:delete, "#@base_url/lists/developers%40mailgun.net/members/#@encoded_address")

      @client.delete_list_member('developers@mailgun.net', @address).must_be_instance_of(Mailgunner::Response)
    end
  end

  describe 'get_list_stats method' do
    it 'fetches the list stats resource and returns a response object' do
      stub_request(:get, "#@base_url/lists/developers%40mailgun.net/stats")

      @client.get_list_stats('developers@mailgun.net').must_be_instance_of(Mailgunner::Response)
    end
  end

  describe 'when initialized with a different json implementation' do
    it 'emits a deprecation warning' do
      Kernel.expects(:warn).with(regexp_matches(/Mailgunner::Client :json option is deprecated/))

      Mailgunner::Client.new(domain: @domain, api_key: @api_key, json: stub)
    end
  end
end
