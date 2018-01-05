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

    @base_url = 'https://@api.mailgun.net/v3'

    @json_response_object = {'key' => 'value'}

    @client = Mailgunner::Client.new(domain: @domain, api_key: @api_key)

    @address = 'user@example.com'

    @encoded_address = 'user%40example.com'

    @login = 'bob.bar'

    @id = 'idxxx'
  end

  def stub(http_method, url, body: nil, headers: nil)
    headers ||= {}
    headers['User-Agent'] = /\ARuby\/\d+\.\d+\.\d+ Mailgunner\/\d+\.\d+\.\d+\z/

    params = {basic_auth: ['api', @api_key]}
    params[:headers] = headers
    params[:body] = body if body

    response_headers = {'Content-Type' => 'application/json;charset=utf-8'}
    response_body = '{"key":"value"}'

    stub_request(http_method, url).with(params).to_return(headers: response_headers, body: response_body)
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

      ENV.delete('MAILGUN_SMTP_LOGIN')
    end
  end

  describe 'api_key method' do
    it 'returns the value passed to the constructor' do
      @client.api_key.must_equal(@api_key)
    end

    it 'defaults to the value of MAILGUN_API_KEY environment variable' do
      ENV['MAILGUN_API_KEY'] = @api_key

      Mailgunner::Client.new(domain: @domain).api_key.must_equal(@api_key)

      ENV.delete('MAILGUN_API_KEY')
    end
  end

  describe 'validate_address method' do
    it 'calls the address validate resource with the given email address and returns the response object' do
      stub(:get, "#@base_url/address/validate?address=#@encoded_address")

      @client.validate_address(@address).must_equal(@json_response_object)
    end
  end

  describe 'parse_addresses method' do
    it 'calls the address parse resource with the given email addresses and returns the response object' do
      stub(:get, "#@base_url/address/parse?addresses=bob%40example.com%2Ceve%40example.com")

      @client.parse_addresses(['bob@example.com', 'eve@example.com']).must_equal(@json_response_object)
    end
  end

  describe 'get_message method' do
    it 'fetches the domain message resource with the given id and returns the response object' do
      stub(:get, "#@base_url/domains/#@domain/messages/#@id")

      @client.get_message(@id).must_equal(@json_response_object)
    end
  end

  describe 'get_mime_message method' do
    it 'fetches the domain message resource with the given key and returns the response object' do
      stub(:get, "#@base_url/domains/#@domain/messages/#@id", headers: {'Accept' => 'message/rfc2822'})

      @client.get_mime_message(@id).must_equal(@json_response_object)
    end
  end

  describe 'send_message method' do
    it 'posts to the domain messages resource and returns the response object' do
      stub(:post, "#@base_url/#@domain/messages", body: "to=#@encoded_address")

      @client.send_message({to: @address}).must_equal(@json_response_object)
    end

    it 'raises an exception if the domain is not provided' do
      @client = Mailgunner::Client.new(api_key: @api_key)

      exception = proc { @client.send_message({}) }.must_raise(Mailgunner::Error)
      exception.message.must_include('No domain provided')
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

    it 'posts to the domain messages resource and returns the response object' do
      stub(:post, "#@base_url/#@domain/messages.mime")

      @client.send_mime(@mail).must_equal(@json_response_object)
    end

    it 'includes all recipients of the message' do
      @mail.cc = 'carol@example.com'
      @mail.bcc = 'dave@example.com'

      stub(:post, "#@base_url/#@domain/messages.mime")

      recipients = 'alice@example.com,carol@example.com,dave@example.com'

      Net::HTTP::Post.any_instance.expects(:set_form).with(includes(['to', recipients]), 'multipart/form-data')

      @client.send_mime(@mail)
    end
  end

  describe 'delete_message method' do
    it 'deletes the domain message resource with the given key and returns the response object' do
      stub(:delete, "#@base_url/domains/#@domain/messages/#@id")

      @client.delete_message(@id).must_equal(@json_response_object)
    end
  end

  describe 'get_domains method' do
    it 'fetches the domains resource and returns the response object' do
      stub(:get, "#@base_url/domains")

      @client.get_domains.must_equal(@json_response_object)
    end
  end

  describe 'get_domain method' do
    it 'fetches the domain resource and returns the response object' do
      stub(:get, "#@base_url/domains/#@domain")

      @client.get_domain(@domain).must_equal(@json_response_object)
    end
  end

  describe 'add_domain method' do
    it 'posts to the domains resource and returns the response object' do
      stub(:post, "#@base_url/domains", body: "name=#@domain")

      @client.add_domain({name: @domain}).must_equal(@json_response_object)
    end
  end

  describe 'delete_domain method' do
    it 'deletes the domain resource with the given name and returns the response object' do
      stub(:delete, "#@base_url/domains/#@domain")

      @client.delete_domain(@domain).must_equal(@json_response_object)
    end
  end

  describe 'get_credentials method' do
    it 'fetches the domain credentials resource and returns the response object' do
      stub(:get, "#@base_url/domains/#@domain/credentials")

      @client.get_credentials.must_equal(@json_response_object)
    end
  end

  describe 'add_credentials method' do
    it 'posts to the domain credentials resource and returns the response object' do
      stub(:post, "#@base_url/domains/#@domain/credentials", body: "login=#@login")

      @client.add_credentials(login: @login).must_equal(@json_response_object)
    end
  end

  describe 'update_credentials method' do
    it 'updates the domain credentials resource with the given login and returns the response object' do
      stub(:put, "#@base_url/domains/#@domain/credentials/#@login", body: 'password=secret')

      @client.update_credentials(@login, {password: 'secret'}).must_equal(@json_response_object)
    end
  end

  describe 'delete_credentials method' do
    it 'deletes the domain credentials resource with the given login and returns the response object' do
      stub(:delete, "#@base_url/domains/#@domain/credentials/#@login")

      @client.delete_credentials(@login).must_equal(@json_response_object)
    end
  end

  describe 'get_connection_settings method' do
    it 'fetches the domain connection settings resource and returns the response object' do
      stub(:get, "#@base_url/domains/#@domain/connection")

      @client.get_connection_settings.must_equal(@json_response_object)
    end
  end

  describe 'update_connection_settings method' do
    it 'updates the domain connection settings resource and returns the response object' do
      stub(:put, "#@base_url/domains/#@domain/connection", body: 'require_tls=true')

      @client.update_connection_settings({require_tls: true}).must_equal(@json_response_object)
    end
  end

  describe 'get_unsubscribes method' do
    it 'fetches the domain unsubscribes resource and returns the response object' do
      stub(:get, "#@base_url/#@domain/unsubscribes")

      @client.get_unsubscribes.must_equal(@json_response_object)
    end

    it 'encodes skip and limit parameters' do
      stub(:get, "#@base_url/#@domain/unsubscribes?skip=1&limit=2")

      @client.get_unsubscribes(skip: 1, limit: 2)
    end
  end

  describe 'get_unsubscribe method' do
    it 'fetches the unsubscribe resource with the given address and returns the response object' do
      stub(:get, "#@base_url/#@domain/unsubscribes/#@encoded_address")

      @client.get_unsubscribe(@address).must_equal(@json_response_object)
    end
  end

  describe 'delete_unsubscribe method' do
    it 'deletes the domain unsubscribe resource with the given address and returns the response object' do
      stub(:delete, "#@base_url/#@domain/unsubscribes/#@encoded_address")

      @client.delete_unsubscribe(@address).must_equal(@json_response_object)
    end
  end

  describe 'add_unsubscribe method' do
    it 'posts to the domain unsubscribes resource and returns the response object' do
      stub(:post, "#@base_url/#@domain/unsubscribes", body: "address=#@encoded_address")

      @client.add_unsubscribe({address: @address}).must_equal(@json_response_object)
    end
  end

  describe 'get_complaints method' do
    it 'fetches the domain complaints resource and returns the response object' do
      stub(:get, "#@base_url/#@domain/complaints")

      @client.get_complaints.must_equal(@json_response_object)
    end

    it 'encodes skip and limit parameters' do
      stub(:get, "#@base_url/#@domain/complaints?skip=1&limit=2")

      @client.get_complaints(skip: 1, limit: 2)
    end
  end

  describe 'get_complaint method' do
    it 'fetches the complaint resource with the given address and returns the response object' do
      stub(:get, "#@base_url/#@domain/complaints/#@encoded_address")

      @client.get_complaint(@address).must_equal(@json_response_object)
    end
  end

  describe 'add_complaint method' do
    it 'posts to the domain complaints resource and returns the response object' do
      stub(:post, "#@base_url/#@domain/complaints", body: "address=#@encoded_address")

      @client.add_complaint({address: @address}).must_equal(@json_response_object)
    end
  end

  describe 'delete_complaint method' do
    it 'deletes the domain complaint resource with the given address and returns the response object' do
      stub(:delete, "#@base_url/#@domain/complaints/#@encoded_address")

      @client.delete_complaint(@address).must_equal(@json_response_object)
    end
  end

  describe 'get_bounces method' do
    it 'fetches the domain bounces resource and returns the response object' do
      stub(:get, "#@base_url/#@domain/bounces")

      @client.get_bounces.must_equal(@json_response_object)
    end

    it 'encodes skip and limit parameters' do
      stub(:get, "#@base_url/#@domain/bounces?skip=1&limit=2")

      @client.get_bounces(skip: 1, limit: 2)
    end
  end

  describe 'get_bounce method' do
    it 'fetches the bounce resource with the given address and returns the response object' do
      stub(:get, "#@base_url/#@domain/bounces/#@encoded_address")

      @client.get_bounce(@address).must_equal(@json_response_object)
    end
  end

  describe 'add_bounce method' do
    it 'posts to the domain bounces resource and returns the response object' do
      stub(:post, "#@base_url/#@domain/bounces", body: "address=#@encoded_address")

      @client.add_bounce({address: @address}).must_equal(@json_response_object)
    end
  end

  describe 'delete_bounce method' do
    it 'deletes the domain bounce resource with the given address and returns the response object' do
      stub(:delete, "#@base_url/#@domain/bounces/#@encoded_address")

      @client.delete_bounce(@address).must_equal(@json_response_object)
    end
  end

  describe 'delete_bounces method' do
    it 'deletes the domain bounces resource and returns the response object' do
      stub(:delete, "#@base_url/#@domain/bounces")

      @client.delete_bounces.must_equal(@json_response_object)
    end
  end

  describe 'get_stats method' do
    before do
      Kernel.stubs(:warn)
    end

    it 'fetches the domain stats resource and returns the response object' do
      stub(:get, "#@base_url/#@domain/stats")

      @client.get_stats.must_equal(@json_response_object)
    end

    it 'encodes skip and limit parameters' do
      stub(:get, "#@base_url/#@domain/stats?skip=1&limit=2")

      @client.get_stats(skip: 1, limit: 2)
    end

    it 'encodes an event parameter with multiple values' do
      WebMock::Config.instance.query_values_notation = :flat_array

      stub(:get, "#@base_url/#@domain/stats?event=opened&event=sent")

      @client.get_stats(event: %w(sent opened))

      WebMock::Config.instance.query_values_notation = nil
    end

    it 'emits a deprecation warning' do
      stub(:get, "#@base_url/#@domain/stats")

      Kernel.expects(:warn).with(regexp_matches(/Mailgunner::Client#get_stats is deprecated/))

      @client.get_stats
    end
  end

  describe 'get_total_stats method' do
    it 'fetches the domain total stats resource and returns the response object' do
      stub(:get, "#@base_url/#@domain/stats/total?event=delivered")

      @client.get_total_stats(event: 'delivered').must_equal(@json_response_object)
    end

    it 'encodes optional parameters' do
      stub(:get, "#@base_url/#@domain/stats/total?event=delivered&resolution=hour")

      @client.get_total_stats(event: 'delivered', resolution: 'hour')
    end

    it 'encodes an event parameter with multiple values' do
      WebMock::Config.instance.query_values_notation = :flat_array

      stub(:get, "#@base_url/#@domain/stats/total?event=delivered&event=accepted")

      @client.get_total_stats(event: %w(accepted delivered))

      WebMock::Config.instance.query_values_notation = nil
    end
  end

  describe 'get_events method' do
    it 'fetches the domain events resource and returns the response object' do
      stub(:get, "#@base_url/#@domain/events")

      @client.get_events.must_equal(@json_response_object)
    end

    it 'encodes optional parameters' do
      stub(:get, "#@base_url/#@domain/events?event=accepted&limit=10")

      @client.get_events(event: 'accepted', limit: 10)
    end
  end

  describe 'get_tags method' do
    it 'fetches the domain tags resource and returns the response object' do
      stub(:get, "#@base_url/#@domain/tags")

      @client.get_tags.must_equal(@json_response_object)
    end

    it 'encodes optional limit parameter' do
      stub(:get, "#@base_url/#@domain/tags?limit=2")

      @client.get_tags(limit: 2)
    end
  end

  describe 'get_tag method' do
    it 'fetches the domain tag resource with the given id and returns the response object' do
      stub(:get, "#@base_url/#@domain/tags/#@id")

      @client.get_tag(@id).must_equal(@json_response_object)
    end
  end

  describe 'update_tag method' do
    it 'updates the domain tag resource with the given id and returns the response object' do
      stub(:put, "#@base_url/#@domain/tags/#@id", body: 'description=Tag+description')

      @client.update_tag(@id, {description: 'Tag description'}).must_equal(@json_response_object)
    end
  end

  describe 'get_tag_stats method' do
    it 'fetches the domain tag stats resource with the given id and returns the response object' do
      stub(:get, "#@base_url/#@domain/tags/#@id/stats?event=accepted")

      @client.get_tag_stats(@id, event: 'accepted').must_equal(@json_response_object)
    end
  end

  describe 'delete_tag method' do
    it 'deletes the domain tag resource with the given id and returns the response object' do
      stub(:delete, "#@base_url/#@domain/tags/#@id")

      @client.delete_tag(@id).must_equal(@json_response_object)
    end
  end

  describe 'get_routes method' do
    it 'fetches the routes resource and returns the response object' do
      stub(:get, "#@base_url/routes")

      @client.get_routes.must_equal(@json_response_object)
    end

    it 'encodes skip and limit parameters' do
      stub(:get, "#@base_url/routes?skip=1&limit=2")

      @client.get_routes(skip: 1, limit: 2)
    end
  end

  describe 'get_route method' do
    it 'fetches the route resource with the given id and returns the response object' do
      stub(:get, "#@base_url/routes/#@id")

      @client.get_route(@id).must_equal(@json_response_object)
    end
  end

  describe 'add_route method' do
    it 'posts to the routes resource and returns the response object' do
      stub(:post, "#@base_url/routes", body: 'description=Example+route&priority=1')

      @client.add_route({description: 'Example route', priority: 1}).must_equal(@json_response_object)
    end
  end

  describe 'update_route method' do
    it 'updates the route resource with the given id and returns the response object' do
      stub(:put, "#@base_url/routes/#@id", body: 'priority=10')

      @client.update_route(@id, {priority: 10}).must_equal(@json_response_object)
    end
  end

  describe 'delete_route method' do
    it 'deletes the route resource with the given id and returns the response object' do
      stub(:delete, "#@base_url/routes/#@id")

      @client.delete_route(@id).must_equal(@json_response_object)
    end
  end

  describe 'get_webhooks method' do
    it 'fetches the domain webhooks resource and returns the response object' do
      stub(:get, "#@base_url/domains/#@domain/webhooks")

      @client.get_webhooks.must_equal(@json_response_object)
    end
  end

  describe 'get_webhook method' do
    it 'fetches the domain webhook resource with the given id and returns the response object' do
      stub(:get, "#@base_url/domains/#@domain/webhooks/#@id")

      @client.get_webhook(@id).must_equal(@json_response_object)
    end
  end

  describe 'add_webhook method' do
    it 'posts to the domain webhooks resource and returns the response object' do
      attributes = {id: @id, url: 'http://example.com/webhook'}

      stub(:post, "#@base_url/domains/#@domain/webhooks", body: attributes)

      @client.add_webhook(attributes).must_equal(@json_response_object)
    end
  end

  describe 'update_webhook method' do
    it 'updates the domain webhook resource with the given id and returns the response object' do
      attributes = {url: 'http://example.com/webhook'}

      stub(:put, "#@base_url/domains/#@domain/webhooks/#@id", body: attributes)

      @client.update_webhook(@id, attributes).must_equal(@json_response_object)
    end
  end

  describe 'delete_webhook method' do
    it 'deletes the domain webhook resource with the given address and returns the response object' do
      stub(:delete, "#@base_url/domains/#@domain/webhooks/#@id")

      @client.delete_webhook(@id).must_equal(@json_response_object)
    end
  end

  describe 'get_campaigns method' do
    it 'fetches the domain campaigns resource and returns the response object' do
      stub(:get, "#@base_url/#@domain/campaigns")

      @client.get_campaigns.must_equal(@json_response_object)
    end

    it 'encodes skip and limit parameters' do
      stub(:get, "#@base_url/#@domain/campaigns?skip=1&limit=2")

      @client.get_campaigns(skip: 1, limit: 2)
    end
  end

  describe 'get_campaign method' do
    it 'fetches the campaign resource with the given id and returns the response object' do
      stub(:get, "#@base_url/#@domain/campaigns/#@id")

      @client.get_campaign(@id).must_equal(@json_response_object)
    end
  end

  describe 'add_campaign method' do
    it 'posts to the domain campaigns resource and returns the response object' do
      stub(:post, "#@base_url/#@domain/campaigns", body: "id=#@id")

      @client.add_campaign({id: @id}).must_equal(@json_response_object)
    end
  end

  describe 'update_campaign method' do
    it 'updates the campaign resource and returns the response object' do
      stub(:put, "#@base_url/#@domain/campaigns/#@id", body: 'name=Example+Campaign')

      @client.update_campaign(@id, {name: 'Example Campaign'}).must_equal(@json_response_object)
    end
  end

  describe 'delete_campaign method' do
    it 'deletes the domain campaign resource with the given id and returns the response object' do
      stub(:delete, "#@base_url/#@domain/campaigns/#@id")

      @client.delete_campaign(@id).must_equal(@json_response_object)
    end
  end

  describe 'get_campaign_events method' do
    it 'fetches the domain campaign events resource and returns the response object' do
      stub(:get, "#@base_url/#@domain/campaigns/#@id/events")

      @client.get_campaign_events(@id).must_equal(@json_response_object)
    end

    it 'encodes the optional parameters' do
      stub(:get, "#@base_url/#@domain/campaigns/#@id/events?country=US&limit=100")

      @client.get_campaign_events(@id, country: 'US', limit: 100)
    end
  end

  describe 'get_campaign_stats method' do
    it 'fetches the domain campaign stats resource and returns the response object' do
      stub(:get, "#@base_url/#@domain/campaigns/#@id/stats")

      @client.get_campaign_stats(@id).must_equal(@json_response_object)
    end

    it 'encodes the optional parameters' do
      stub(:get, "#@base_url/#@domain/campaigns/#@id/stats?groupby=dailyhour")

      @client.get_campaign_stats(@id, groupby: 'dailyhour')
    end
  end

  describe 'get_campaign_clicks method' do
    it 'fetches the domain campaign clicks resource and returns the response object' do
      stub(:get, "#@base_url/#@domain/campaigns/#@id/clicks")

      @client.get_campaign_clicks(@id).must_equal(@json_response_object)
    end

    it 'encodes the optional parameters' do
      stub(:get, "#@base_url/#@domain/campaigns/#@id/clicks?groupby=month&limit=100")

      @client.get_campaign_clicks(@id, groupby: 'month', limit: 100)
    end
  end

  describe 'get_campaign_opens method' do
    it 'fetches the domain campaign opens resource and returns the response object' do
      stub(:get, "#@base_url/#@domain/campaigns/#@id/opens")

      @client.get_campaign_opens(@id).must_equal(@json_response_object)
    end

    it 'encodes the optional parameters' do
      stub(:get, "#@base_url/#@domain/campaigns/#@id/opens?groupby=month&limit=100")

      @client.get_campaign_opens(@id, groupby: 'month', limit: 100)
    end
  end

  describe 'get_campaign_unsubscribes method' do
    it 'fetches the domain campaign unsubscribes resource and returns the response object' do
      stub(:get, "#@base_url/#@domain/campaigns/#@id/unsubscribes")

      @client.get_campaign_unsubscribes(@id).must_equal(@json_response_object)
    end

    it 'encodes the optional parameters' do
      stub(:get, "#@base_url/#@domain/campaigns/#@id/unsubscribes?groupby=month&limit=100")

      @client.get_campaign_unsubscribes(@id, groupby: 'month', limit: 100)
    end
  end

  describe 'get_campaign_complaints method' do
    it 'fetches the domain campaign complaints resource and returns the response object' do
      stub(:get, "#@base_url/#@domain/campaigns/#@id/complaints")

      @client.get_campaign_complaints(@id).must_equal(@json_response_object)
    end

    it 'encodes the optional parameters' do
      stub(:get, "#@base_url/#@domain/campaigns/#@id/complaints?groupby=month&limit=100")

      @client.get_campaign_complaints(@id, groupby: 'month', limit: 100)
    end
  end

  describe 'get_lists method' do
    it 'fetches the lists resource and returns the response object' do
      stub(:get, "#@base_url/lists")

      @client.get_lists.must_equal(@json_response_object)
    end

    it 'encodes skip and limit parameters' do
      stub(:get, "#@base_url/lists?skip=1&limit=2")

      @client.get_lists(skip: 1, limit: 2)
    end
  end

  describe 'get_list method' do
    it 'fetches the list resource with the given address and returns the response object' do
      stub(:get, "#@base_url/lists/developers%40mailgun.net")

      @client.get_list('developers@mailgun.net').must_equal(@json_response_object)
    end
  end

  describe 'add_list method' do
    it 'posts to the lists resource and returns the response object' do
      stub(:post, "#@base_url/lists", body: 'address=developers%40mailgun.net')

      @client.add_list({address: 'developers@mailgun.net'}).must_equal(@json_response_object)
    end
  end

  describe 'update_list method' do
    it 'updates the list resource and returns the response object' do
      stub(:put, "#@base_url/lists/developers%40mailgun.net", body: 'name=Example+list')

      @client.update_list('developers@mailgun.net', {name: 'Example list'}).must_equal(@json_response_object)
    end
  end

  describe 'delete_list method' do
    it 'deletes the list resource with the given address and returns the response object' do
      stub(:delete, "#@base_url/lists/developers%40mailgun.net")

      @client.delete_list('developers@mailgun.net').must_equal(@json_response_object)
    end
  end

  describe 'get_list_members method' do
    it 'fetches the list members resource and returns the response object' do
      stub(:get, "#@base_url/lists/developers%40mailgun.net/members")

      @client.get_list_members('developers@mailgun.net').must_equal(@json_response_object)
    end

    it 'encodes skip and limit parameters' do
      stub(:get, "#@base_url/lists/developers%40mailgun.net/members?skip=1&limit=2")

      @client.get_list_members('developers@mailgun.net', skip: 1, limit: 2)
    end
  end

  describe 'get_list_member method' do
    it 'fetches the list member resource with the given address and returns the response object' do
      stub(:get, "#@base_url/lists/developers%40mailgun.net/members/#@encoded_address")

      @client.get_list_member('developers@mailgun.net', @address).must_equal(@json_response_object)
    end
  end

  describe 'add_list_member method' do
    it 'posts to the list members resource and returns the response object' do
      stub(:post, "#@base_url/lists/developers%40mailgun.net/members", body: "address=#@encoded_address")

      @client.add_list_member('developers@mailgun.net', {address: @address}).must_equal(@json_response_object)
    end
  end

  describe 'update_list_member method' do
    it 'updates the list member resource with the given address and returns the response object' do
      stub(:put, "#@base_url/lists/developers%40mailgun.net/members/#@encoded_address", body: 'subscribed=no')

      @client.update_list_member('developers@mailgun.net', @address, {subscribed: 'no'}).must_equal(@json_response_object)
    end
  end

  describe 'delete_list_member method' do
    it 'deletes the list member resource with the given address and returns the response object' do
      stub(:delete, "#@base_url/lists/developers%40mailgun.net/members/#@encoded_address")

      @client.delete_list_member('developers@mailgun.net', @address).must_equal(@json_response_object)
    end
  end

  it 'raises an exception for authentication errors' do
    stub_request(:any, /api\.mailgun\.net/).to_return(status: 401)

    proc { @client.get_message(@id) }.must_raise(Mailgunner::AuthenticationError)
  end

  it 'raises an exception for client errors' do
    stub_request(:any, /api\.mailgun\.net/).to_return(status: 400)

    proc { @client.get_message(@id) }.must_raise(Mailgunner::ClientError)
  end

  it 'raises an exception for server errors' do
    stub_request(:any, /api\.mailgun\.net/).to_return(status: 500)

    proc { @client.get_message(@id) }.must_raise(Mailgunner::ServerError)
  end
end
