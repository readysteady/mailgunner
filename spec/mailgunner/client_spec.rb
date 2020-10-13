require 'minitest/global_expectations/autorun'
require 'webmock/minitest'
require 'mocha/minitest'
require 'mailgunner'
require 'json'
require 'mail'

describe 'Mailgunner::Client' do
  let(:domain) { 'samples.mailgun.org' }
  let(:api_key) { 'api_key_xxx' }
  let(:address) { 'user@example.com' }
  let(:encoded_address) { 'user%40example.com' }
  let(:list_id) { 'list_xxx' }
  let(:list_address) { 'developers@mailgun.net' }
  let(:login) { 'bob.bar' }
  let(:id) { 'id_xxx' }
  let(:base_url) { 'https://api.mailgun.net' }
  let(:response_struct) { Mailgunner::Struct.new('key' => 'value') }
  let(:client) { Mailgunner::Client.new(domain: domain, api_key: api_key) }

  def stub(http_method, url, body: nil, headers: nil)
    headers ||= {}
    headers['User-Agent'] = /\ARuby\/\d+\.\d+\.\d+ Mailgunner\/\d+\.\d+\.\d+\z/

    params = {basic_auth: ['api', api_key]}
    params[:headers] = headers
    params[:body] = body if body

    response_headers = {'Content-Type' => 'application/json;charset=utf-8'}
    response_body = '{"key":"value"}'

    stub_request(http_method, url).with(params).to_return(headers: response_headers, body: response_body)
  end

  describe 'validate_address method' do
    it 'returns a response struct' do
      stub(:get, "#{base_url}/v4/address/validate?address=#{encoded_address}")

      client.validate_address(address).must_equal(response_struct)
    end
  end

  describe 'get_bulk_validations method' do
    it 'returns a response struct' do
      stub(:get, "#{base_url}/v4/address/validate/bulk")

      client.get_bulk_validations.must_equal(response_struct)
    end
  end

  describe 'create_bulk_validation method' do
    it 'returns a response struct' do
      stub(:post, "#{base_url}/v4/address/validate/bulk/#{list_id}")

      client.create_bulk_validation(list_id).must_equal(response_struct)
    end
  end

  describe 'get_bulk_validation method' do
    it 'returns a response struct' do
      stub(:get, "#{base_url}/v4/address/validate/bulk/#{list_id}")

      client.get_bulk_validation(list_id).must_equal(response_struct)
    end
  end

  describe 'cancel_bulk_validation method' do
    it 'returns a response struct' do
      stub(:delete, "#{base_url}/v4/address/validate/bulk/#{list_id}")

      client.cancel_bulk_validation(list_id).must_equal(response_struct)
    end
  end

  describe 'get_message method' do
    it 'returns a response struct' do
      stub(:get, "#{base_url}/v3/domains/#{domain}/messages/#{id}")

      client.get_message(id).must_equal(response_struct)
    end
  end

  describe 'get_mime_message method' do
    it 'returns a response struct' do
      stub(:get, "#{base_url}/v3/domains/#{domain}/messages/#{id}", headers: {'Accept' => 'message/rfc2822'})

      client.get_mime_message(id).must_equal(response_struct)
    end
  end

  describe 'send_message method' do
    it 'returns a response struct' do
      stub(:post, "#{base_url}/v3/#{domain}/messages", body: "to=#{encoded_address}")

      client.send_message(to: address).must_equal(response_struct)
    end

    it 'raises an exception if the domain is not provided' do
      client = Mailgunner::Client.new(api_key: api_key)

      exception = proc { client.send_message({}) }.must_raise(Mailgunner::Error)
      exception.message.must_include('No domain provided')
    end

    it 'encodes the message attributes as multipart form data when sending attachments' do
      # TODO
    end
  end

  describe 'send_mime method' do
    let(:mail) {
      Mail.new({
        to: 'alice@example.com',
        from: 'bob@example.com',
        subject: 'Test email',
        body: 'This is a test email'
      })
    }

    it 'returns a response struct' do
      stub(:post, "#{base_url}/v3/#{domain}/messages.mime")

      client.send_mime(mail).must_equal(response_struct)
    end

    it 'includes all recipients of the message' do
      mail.cc = 'carol@example.com'
      mail.bcc = 'dave@example.com'

      stub(:post, "#{base_url}/v3/#{domain}/messages.mime")

      recipients = 'alice@example.com,carol@example.com,dave@example.com'

      Net::HTTP::Post.any_instance.expects(:set_form).with(includes(['to', recipients]), 'multipart/form-data')

      client.send_mime(mail)
    end
  end

  describe 'delete_message method' do
    it 'returns a response struct' do
      stub(:delete, "#{base_url}/v3/domains/#{domain}/messages/#{id}")

      client.delete_message(id).must_equal(response_struct)
    end
  end

  describe 'get_domains method' do
    it 'returns a response struct' do
      stub(:get, "#{base_url}/v3/domains")

      client.get_domains.must_equal(response_struct)
    end
  end

  describe 'get_domain method' do
    it 'returns a response struct' do
      stub(:get, "#{base_url}/v3/domains/#{domain}")

      client.get_domain(domain).must_equal(response_struct)
    end
  end

  describe 'add_domain method' do
    it 'returns a response struct' do
      stub(:post, "#{base_url}/v3/domains", body: "name=#{domain}")

      client.add_domain(name: domain).must_equal(response_struct)
    end
  end

  describe 'delete_domain method' do
    it 'returns a response struct' do
      stub(:delete, "#{base_url}/v3/domains/#{domain}")

      client.delete_domain(domain).must_equal(response_struct)
    end
  end

  describe 'verify_domain method' do
    it 'returns a response struct' do
      stub(:put, "#{base_url}/v3/domains/#{domain}/verify")

      client.verify_domain(domain).must_equal(response_struct)
    end
  end

  describe 'get_credentials method' do
    it 'returns a response struct' do
      stub(:get, "#{base_url}/v3/domains/#{domain}/credentials")

      client.get_credentials.must_equal(response_struct)
    end
  end

  describe 'add_credentials method' do
    it 'returns a response struct' do
      stub(:post, "#{base_url}/v3/domains/#{domain}/credentials", body: "login=#{login}")

      client.add_credentials(login: login).must_equal(response_struct)
    end
  end

  describe 'update_credentials method' do
    it 'returns a response struct' do
      stub(:put, "#{base_url}/v3/domains/#{domain}/credentials/#{login}", body: 'password=secret')

      client.update_credentials(login, password: 'secret').must_equal(response_struct)
    end
  end

  describe 'delete_credentials method' do
    it 'returns a response struct' do
      stub(:delete, "#{base_url}/v3/domains/#{domain}/credentials/#{login}")

      client.delete_credentials(login).must_equal(response_struct)
    end
  end

  describe 'get_connection_settings method' do
    it 'returns a response struct' do
      stub(:get, "#{base_url}/v3/domains/#{domain}/connection")

      client.get_connection_settings.must_equal(response_struct)
    end
  end

  describe 'update_connection_settings method' do
    it 'returns a response struct' do
      stub(:put, "#{base_url}/v3/domains/#{domain}/connection", body: 'require_tls=true')

      client.update_connection_settings({require_tls: true}).must_equal(response_struct)
    end
  end

  describe 'get_tracking_settings method' do
    it 'returns a response struct' do
      stub(:get, "#{base_url}/v3/domains/#{domain}/tracking")

      client.get_tracking_settings.must_equal(response_struct)
    end
  end

  describe 'update_open_tracking_settings method' do
    it 'returns a response struct' do
      stub(:put, "#{base_url}/v3/domains/#{domain}/tracking/open")

      client.update_open_tracking_settings(active: 'yes').must_equal(response_struct)
    end
  end

  describe 'update_click_tracking_settings method' do
    it 'returns a response struct' do
      stub(:put, "#{base_url}/v3/domains/#{domain}/tracking/click")

      client.update_click_tracking_settings(active: 'yes').must_equal(response_struct)
    end
  end

  describe 'update_unsubscribe_tracking_settings method' do
    it 'returns a response struct' do
      stub(:put, "#{base_url}/v3/domains/#{domain}/tracking/unsubscribe")

      client.update_unsubscribe_tracking_settings(active: 'true').must_equal(response_struct)
    end
  end

  describe 'update_dkim_authority method' do
    it 'returns a response struct' do
      stub(:put, "#{base_url}/v3/domains/#{domain}/dkim_authority")

      client.update_dkim_authority(self: true).must_equal(response_struct)
    end
  end

  describe 'update_dkim_selector method' do
    it 'returns a response struct' do
      stub(:put, "#{base_url}/v3/domains/#{domain}/dkim_selector")

      client.update_dkim_selector(dkim_selector: 'DKIM selector').must_equal(response_struct)
    end
  end

  describe 'update_web_prefix method' do
    it 'returns a response struct' do
      stub(:put, "#{base_url}/v3/domains/#{domain}/web_prefix")

      client.update_web_prefix(web_prefix: 'tracking.example.com').must_equal(response_struct)
    end
  end

  describe 'get_unsubscribes method' do
    it 'returns a response struct' do
      stub(:get, "#{base_url}/v3/#{domain}/unsubscribes")

      client.get_unsubscribes.must_equal(response_struct)
    end

    it 'encodes skip and limit parameters' do
      stub(:get, "#{base_url}/v3/#{domain}/unsubscribes?skip=1&limit=2")

      client.get_unsubscribes(skip: 1, limit: 2)
    end
  end

  describe 'get_unsubscribe method' do
    it 'returns a response struct' do
      stub(:get, "#{base_url}/v3/#{domain}/unsubscribes/#{encoded_address}")

      client.get_unsubscribe(address).must_equal(response_struct)
    end
  end

  describe 'delete_unsubscribe method' do
    it 'returns a response struct' do
      stub(:delete, "#{base_url}/v3/#{domain}/unsubscribes/#{encoded_address}")

      client.delete_unsubscribe(address).must_equal(response_struct)
    end
  end

  describe 'add_unsubscribe method' do
    it 'returns a response struct' do
      stub(:post, "#{base_url}/v3/#{domain}/unsubscribes", body: "address=#{encoded_address}")

      client.add_unsubscribe(address: address).must_equal(response_struct)
    end
  end

  describe 'get_complaints method' do
    it 'returns a response struct' do
      stub(:get, "#{base_url}/v3/#{domain}/complaints")

      client.get_complaints.must_equal(response_struct)
    end

    it 'encodes skip and limit parameters' do
      stub(:get, "#{base_url}/v3/#{domain}/complaints?skip=1&limit=2")

      client.get_complaints(skip: 1, limit: 2)
    end
  end

  describe 'get_complaint method' do
    it 'returns a response struct' do
      stub(:get, "#{base_url}/v3/#{domain}/complaints/#{encoded_address}")

      client.get_complaint(address).must_equal(response_struct)
    end
  end

  describe 'add_complaint method' do
    it 'returns a response struct' do
      stub(:post, "#{base_url}/v3/#{domain}/complaints", body: "address=#{encoded_address}")

      client.add_complaint(address: address).must_equal(response_struct)
    end
  end

  describe 'delete_complaint method' do
    it 'returns a response struct' do
      stub(:delete, "#{base_url}/v3/#{domain}/complaints/#{encoded_address}")

      client.delete_complaint(address).must_equal(response_struct)
    end
  end

  describe 'get_bounces method' do
    it 'returns a response struct' do
      stub(:get, "#{base_url}/v3/#{domain}/bounces")

      client.get_bounces.must_equal(response_struct)
    end

    it 'encodes skip and limit parameters' do
      stub(:get, "#{base_url}/v3/#{domain}/bounces?skip=1&limit=2")

      client.get_bounces(skip: 1, limit: 2)
    end
  end

  describe 'get_bounce method' do
    it 'returns a response struct' do
      stub(:get, "#{base_url}/v3/#{domain}/bounces/#{encoded_address}")

      client.get_bounce(address).must_equal(response_struct)
    end
  end

  describe 'add_bounce method' do
    it 'returns a response struct' do
      stub(:post, "#{base_url}/v3/#{domain}/bounces", body: "address=#{encoded_address}")

      client.add_bounce(address: address).must_equal(response_struct)
    end
  end

  describe 'delete_bounce method' do
    it 'returns a response struct' do
      stub(:delete, "#{base_url}/v3/#{domain}/bounces/#{encoded_address}")

      client.delete_bounce(address).must_equal(response_struct)
    end
  end

  describe 'delete_bounces method' do
    it 'returns a response struct' do
      stub(:delete, "#{base_url}/v3/#{domain}/bounces")

      client.delete_bounces.must_equal(response_struct)
    end
  end

  describe 'get_whitelists method' do
    it 'returns a response struct' do
      stub(:get, "#{base_url}/v3/#{domain}/whitelists")

      client.get_whitelists.must_equal(response_struct)
    end
  end

  describe 'get_whitelist method' do
    it 'returns a response struct' do
      stub(:get, "#{base_url}/v3/#{domain}/whitelists/#{encoded_address}")

      client.get_whitelist(address).must_equal(response_struct)
    end
  end

  describe 'add_whitelist method' do
    it 'returns a response struct' do
      stub(:post, "#{base_url}/v3/#{domain}/whitelists", body: "address=#{encoded_address}")

      client.add_whitelist(address: address).must_equal(response_struct)
    end
  end

  describe 'delete_whitelist method' do
    it 'returns a response struct' do
      stub(:delete, "#{base_url}/v3/#{domain}/whitelists/#{encoded_address}")

      client.delete_whitelist(address).must_equal(response_struct)
    end
  end

  describe 'get_total_stats method' do
    it 'returns a response struct' do
      stub(:get, "#{base_url}/v3/#{domain}/stats/total?event=delivered")

      client.get_total_stats(event: 'delivered').must_equal(response_struct)
    end

    it 'encodes optional parameters' do
      stub(:get, "#{base_url}/v3/#{domain}/stats/total?event=delivered&resolution=hour")

      client.get_total_stats(event: 'delivered', resolution: 'hour')
    end

    it 'encodes an event parameter with multiple values' do
      WebMock::Config.instance.query_values_notation = :flat_array

      stub(:get, "#{base_url}/v3/#{domain}/stats/total?event=delivered&event=accepted")

      client.get_total_stats(event: %w(accepted delivered))

      WebMock::Config.instance.query_values_notation = nil
    end
  end

  describe 'get_events method' do
    it 'returns a response struct' do
      stub(:get, "#{base_url}/v3/#{domain}/events")

      client.get_events.must_equal(response_struct)
    end

    it 'encodes optional parameters' do
      stub(:get, "#{base_url}/v3/#{domain}/events?event=accepted&limit=10")

      client.get_events(event: 'accepted', limit: 10)
    end
  end

  describe 'get_tags method' do
    it 'returns a response struct' do
      stub(:get, "#{base_url}/v3/#{domain}/tags")

      client.get_tags.must_equal(response_struct)
    end

    it 'encodes optional limit parameter' do
      stub(:get, "#{base_url}/v3/#{domain}/tags?limit=2")

      client.get_tags(limit: 2)
    end
  end

  describe 'get_tag method' do
    it 'returns a response struct' do
      stub(:get, "#{base_url}/v3/#{domain}/tags/#{id}")

      client.get_tag(id).must_equal(response_struct)
    end
  end

  describe 'update_tag method' do
    it 'returns a response struct' do
      stub(:put, "#{base_url}/v3/#{domain}/tags/#{id}", body: 'description=Tag+description')

      client.update_tag(id, {description: 'Tag description'}).must_equal(response_struct)
    end
  end

  describe 'get_tag_stats method' do
    it 'returns a response struct' do
      stub(:get, "#{base_url}/v3/#{domain}/tags/#{id}/stats?event=accepted")

      client.get_tag_stats(id, event: 'accepted').must_equal(response_struct)
    end
  end

  describe 'delete_tag method' do
    it 'returns a response struct' do
      stub(:delete, "#{base_url}/v3/#{domain}/tags/#{id}")

      client.delete_tag(id).must_equal(response_struct)
    end
  end

  describe 'get_routes method' do
    it 'returns a response struct' do
      stub(:get, "#{base_url}/v3/routes")

      client.get_routes.must_equal(response_struct)
    end

    it 'encodes skip and limit parameters' do
      stub(:get, "#{base_url}/v3/routes?skip=1&limit=2")

      client.get_routes(skip: 1, limit: 2)
    end
  end

  describe 'get_route method' do
    it 'returns a response struct' do
      stub(:get, "#{base_url}/v3/routes/#{id}")

      client.get_route(id).must_equal(response_struct)
    end
  end

  describe 'add_route method' do
    it 'returns a response struct' do
      stub(:post, "#{base_url}/v3/routes", body: 'description=Example+route&priority=1')

      client.add_route({description: 'Example route', priority: 1}).must_equal(response_struct)
    end
  end

  describe 'update_route method' do
    it 'returns a response struct' do
      stub(:put, "#{base_url}/v3/routes/#{id}", body: 'priority=10')

      client.update_route(id, {priority: 10}).must_equal(response_struct)
    end
  end

  describe 'delete_route method' do
    it 'returns a response struct' do
      stub(:delete, "#{base_url}/v3/routes/#{id}")

      client.delete_route(id).must_equal(response_struct)
    end
  end

  describe 'get_webhooks method' do
    it 'returns a response struct' do
      stub(:get, "#{base_url}/v3/domains/#{domain}/webhooks")

      client.get_webhooks.must_equal(response_struct)
    end
  end

  describe 'get_webhook method' do
    it 'returns a response struct' do
      stub(:get, "#{base_url}/v3/domains/#{domain}/webhooks/#{id}")

      client.get_webhook(id).must_equal(response_struct)
    end
  end

  describe 'add_webhook method' do
    it 'returns a response struct' do
      attributes = {id: id, url: 'http://example.com/webhook'}

      stub(:post, "#{base_url}/v3/domains/#{domain}/webhooks", body: attributes)

      client.add_webhook(attributes).must_equal(response_struct)
    end
  end

  describe 'update_webhook method' do
    it 'returns a response struct' do
      attributes = {url: 'http://example.com/webhook'}

      stub(:put, "#{base_url}/v3/domains/#{domain}/webhooks/#{id}", body: attributes)

      client.update_webhook(id, attributes).must_equal(response_struct)
    end
  end

  describe 'delete_webhook method' do
    it 'returns a response struct' do
      stub(:delete, "#{base_url}/v3/domains/#{domain}/webhooks/#{id}")

      client.delete_webhook(id).must_equal(response_struct)
    end
  end

  describe 'get_all_ips method' do
    it 'returns a response struct' do
      stub(:get, "#{base_url}/v3/ips")

      client.get_all_ips.must_equal(response_struct)
    end
  end

  describe 'get_ip method' do
    it 'returns a response struct' do
      address = '127.0.0.1'

      stub(:get, "#{base_url}/v3/ips/#{address}")

      client.get_ip(address).must_equal(response_struct)
    end
  end

  describe 'get_ips method' do
    it 'returns a response struct' do
      stub(:get, "#{base_url}/v3/domains/#{domain}/ips")

      client.get_ips.must_equal(response_struct)
    end
  end

  describe 'add_ip method' do
    it 'returns a response struct' do
      address = '127.0.0.1'

      stub(:post, "#{base_url}/v3/domains/#{domain}/ips", body: {ip: address})

      client.add_ip(address).must_equal(response_struct)
    end
  end

  describe 'delete_ip method' do
    it 'returns a response struct' do
      address = '127.0.0.1'

      stub(:delete, "#{base_url}/v3/domains/#{domain}/ips/#{address}")

      client.delete_ip(address).must_equal(response_struct)
    end
  end

  describe 'get_lists method' do
    it 'returns a response struct' do
      stub(:get, "#{base_url}/v3/lists/pages")

      client.get_lists.must_equal(response_struct)
    end

    it 'encodes skip and limit parameters' do
      stub(:get, "#{base_url}/v3/lists/pages?skip=1&limit=2")

      client.get_lists(skip: 1, limit: 2)
    end
  end

  describe 'get_list method' do
    it 'returns a response struct' do
      stub(:get, "#{base_url}/v3/lists/developers%40mailgun.net")

      client.get_list(list_address).must_equal(response_struct)
    end
  end

  describe 'add_list method' do
    it 'returns a response struct' do
      stub(:post, "#{base_url}/v3/lists", body: 'address=developers%40mailgun.net')

      client.add_list(address: list_address).must_equal(response_struct)
    end
  end

  describe 'update_list method' do
    it 'returns a response struct' do
      stub(:put, "#{base_url}/v3/lists/developers%40mailgun.net", body: 'name=Example+list')

      client.update_list(list_address, {name: 'Example list'}).must_equal(response_struct)
    end
  end

  describe 'delete_list method' do
    it 'returns a response struct' do
      stub(:delete, "#{base_url}/v3/lists/developers%40mailgun.net")

      client.delete_list(list_address).must_equal(response_struct)
    end
  end

  describe 'get_list_members method' do
    it 'returns a response struct' do
      stub(:get, "#{base_url}/v3/lists/developers%40mailgun.net/members/pages")

      client.get_list_members(list_address).must_equal(response_struct)
    end

    it 'encodes skip and limit parameters' do
      stub(:get, "#{base_url}/v3/lists/developers%40mailgun.net/members/pages?skip=1&limit=2")

      client.get_list_members(list_address, skip: 1, limit: 2)
    end
  end

  describe 'get_list_member method' do
    it 'returns a response struct' do
      stub(:get, "#{base_url}/v3/lists/developers%40mailgun.net/members/#{encoded_address}")

      client.get_list_member(list_address, address).must_equal(response_struct)
    end
  end

  describe 'add_list_member method' do
    it 'returns a response struct' do
      stub(:post, "#{base_url}/v3/lists/developers%40mailgun.net/members", body: "address=#{encoded_address}")

      client.add_list_member(list_address, address: address).must_equal(response_struct)
    end
  end

  describe 'update_list_member method' do
    it 'returns a response struct' do
      stub(:put, "#{base_url}/v3/lists/developers%40mailgun.net/members/#{encoded_address}", body: 'subscribed=no')

      client.update_list_member(list_address, address, {subscribed: 'no'}).must_equal(response_struct)
    end
  end

  describe 'delete_list_member method' do
    it 'returns a response struct' do
      stub(:delete, "#{base_url}/v3/lists/developers%40mailgun.net/members/#{encoded_address}")

      client.delete_list_member(list_address, address).must_equal(response_struct)
    end
  end
end
