require 'spec_helper'

RSpec.describe Mailgunner::Client do
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

  describe '#validate_address' do
    it 'returns a response struct' do
      stub(:get, "#{base_url}/v4/address/validate?address=#{encoded_address}")

      expect(client.validate_address(address)).to eq(response_struct)
    end
  end

  describe '#get_bulk_validations' do
    it 'returns a response struct' do
      stub(:get, "#{base_url}/v4/address/validate/bulk")

      expect(client.get_bulk_validations).to eq(response_struct)
    end
  end

  describe '#create_bulk_validation' do
    it 'returns a response struct' do
      stub(:post, "#{base_url}/v4/address/validate/bulk/#{list_id}")

      expect(client.create_bulk_validation(list_id)).to eq(response_struct)
    end
  end

  describe '#get_bulk_validation' do
    it 'returns a response struct' do
      stub(:get, "#{base_url}/v4/address/validate/bulk/#{list_id}")

      expect(client.get_bulk_validation(list_id)).to eq(response_struct)
    end
  end

  describe '#cancel_bulk_validation' do
    it 'returns a response struct' do
      stub(:delete, "#{base_url}/v4/address/validate/bulk/#{list_id}")

      expect(client.cancel_bulk_validation(list_id)).to eq(response_struct)
    end
  end

  describe '#get_message' do
    it 'returns a response struct' do
      stub(:get, "#{base_url}/v3/domains/#{domain}/messages/#{id}")

      expect(client.get_message(id)).to eq(response_struct)
    end
  end

  describe '#get_mime_message' do
    it 'returns a response struct' do
      stub(:get, "#{base_url}/v3/domains/#{domain}/messages/#{id}", headers: {'Accept' => 'message/rfc2822'})

      expect(client.get_mime_message(id)).to eq(response_struct)
    end
  end

  describe '#send_message' do
    it 'returns a response struct' do
      stub(:post, "#{base_url}/v3/#{domain}/messages", body: "to=#{encoded_address}")

      expect(client.send_message(to: address)).to eq(response_struct)
    end

    it 'raises an exception if the domain is not provided' do
      client = Mailgunner::Client.new(api_key: api_key)

      expect { client.send_message({}) }.to raise_error(Mailgunner::Error) { |exception|
        expect(exception.message).to include('No domain provided')
      }
    end

    it 'encodes the message attributes as multipart form data when sending attachments' do
      # TODO
    end
  end

  describe '#send_mime' do
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

      expect(client.send_mime(mail)).to eq(response_struct)
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

  describe '#delete_message' do
    it 'returns a response struct' do
      stub(:delete, "#{base_url}/v3/domains/#{domain}/messages/#{id}")

      expect(client.delete_message(id)).to eq(response_struct)
    end
  end

  describe '#get_domains' do
    it 'returns a response struct' do
      stub(:get, "#{base_url}/v3/domains")

      expect(client.get_domains).to eq(response_struct)
    end
  end

  describe '#get_domain' do
    it 'returns a response struct' do
      stub(:get, "#{base_url}/v3/domains/#{domain}")

      expect(client.get_domain(domain)).to eq(response_struct)
    end
  end

  describe '#add_domain' do
    it 'returns a response struct' do
      stub(:post, "#{base_url}/v3/domains", body: "name=#{domain}")

      expect(client.add_domain(name: domain)).to eq(response_struct)
    end
  end

  describe '#delete_domain' do
    it 'returns a response struct' do
      stub(:delete, "#{base_url}/v3/domains/#{domain}")

      expect(client.delete_domain(domain)).to eq(response_struct)
    end
  end

  describe '#verify_domain' do
    it 'returns a response struct' do
      stub(:put, "#{base_url}/v3/domains/#{domain}/verify")

      expect(client.verify_domain(domain)).to eq(response_struct)
    end
  end

  describe '#get_credentials' do
    it 'returns a response struct' do
      stub(:get, "#{base_url}/v3/domains/#{domain}/credentials")

      expect(client.get_credentials).to eq(response_struct)
    end
  end

  describe '#add_credentials' do
    it 'returns a response struct' do
      stub(:post, "#{base_url}/v3/domains/#{domain}/credentials", body: "login=#{login}")

      expect(client.add_credentials(login: login)).to eq(response_struct)
    end
  end

  describe '#update_credentials' do
    it 'returns a response struct' do
      stub(:put, "#{base_url}/v3/domains/#{domain}/credentials/#{login}", body: 'password=secret')

      expect(client.update_credentials(login, password: 'secret')).to eq(response_struct)
    end
  end

  describe '#delete_credentials' do
    it 'returns a response struct' do
      stub(:delete, "#{base_url}/v3/domains/#{domain}/credentials/#{login}")

      expect(client.delete_credentials(login)).to eq(response_struct)
    end
  end

  describe '#get_connection_settings' do
    it 'returns a response struct' do
      stub(:get, "#{base_url}/v3/domains/#{domain}/connection")

      expect(client.get_connection_settings).to eq(response_struct)
    end
  end

  describe '#update_connection_settings' do
    it 'returns a response struct' do
      stub(:put, "#{base_url}/v3/domains/#{domain}/connection", body: 'require_tls=true')

      expect(client.update_connection_settings({require_tls: true})).to eq(response_struct)
    end
  end

  describe '#get_tracking_settings' do
    it 'returns a response struct' do
      stub(:get, "#{base_url}/v3/domains/#{domain}/tracking")

      expect(client.get_tracking_settings).to eq(response_struct)
    end
  end

  describe '#update_open_tracking_settings' do
    it 'returns a response struct' do
      stub(:put, "#{base_url}/v3/domains/#{domain}/tracking/open")

      expect(client.update_open_tracking_settings(active: 'yes')).to eq(response_struct)
    end
  end

  describe '#update_click_tracking_settings' do
    it 'returns a response struct' do
      stub(:put, "#{base_url}/v3/domains/#{domain}/tracking/click")

      expect(client.update_click_tracking_settings(active: 'yes')).to eq(response_struct)
    end
  end

  describe '#update_unsubscribe_tracking_settings' do
    it 'returns a response struct' do
      stub(:put, "#{base_url}/v3/domains/#{domain}/tracking/unsubscribe")

      expect(client.update_unsubscribe_tracking_settings(active: 'true')).to eq(response_struct)
    end
  end

  describe '#update_dkim_authority' do
    it 'returns a response struct' do
      stub(:put, "#{base_url}/v3/domains/#{domain}/dkim_authority")

      expect(client.update_dkim_authority(self: true)).to eq(response_struct)
    end
  end

  describe '#update_dkim_selector' do
    it 'returns a response struct' do
      stub(:put, "#{base_url}/v3/domains/#{domain}/dkim_selector")

      expect(client.update_dkim_selector(dkim_selector: 'DKIM selector')).to eq(response_struct)
    end
  end

  describe '#update_web_prefix' do
    it 'returns a response struct' do
      stub(:put, "#{base_url}/v3/domains/#{domain}/web_prefix")

      expect(client.update_web_prefix(web_prefix: 'tracking.example.com')).to eq(response_struct)
    end
  end

  describe '#get_unsubscribes' do
    it 'returns a response struct' do
      stub(:get, "#{base_url}/v3/#{domain}/unsubscribes")

      expect(client.get_unsubscribes).to eq(response_struct)
    end

    it 'encodes skip and limit parameters' do
      stub(:get, "#{base_url}/v3/#{domain}/unsubscribes?skip=1&limit=2")

      client.get_unsubscribes(skip: 1, limit: 2)
    end
  end

  describe '#get_unsubscribe' do
    it 'returns a response struct' do
      stub(:get, "#{base_url}/v3/#{domain}/unsubscribes/#{encoded_address}")

      expect(client.get_unsubscribe(address)).to eq(response_struct)
    end
  end

  describe '#delete_unsubscribe' do
    it 'returns a response struct' do
      stub(:delete, "#{base_url}/v3/#{domain}/unsubscribes/#{encoded_address}")

      expect(client.delete_unsubscribe(address)).to eq(response_struct)
    end
  end

  describe '#add_unsubscribe' do
    it 'returns a response struct' do
      stub(:post, "#{base_url}/v3/#{domain}/unsubscribes", body: "address=#{encoded_address}")

      expect(client.add_unsubscribe(address: address)).to eq(response_struct)
    end
  end

  describe '#get_complaints' do
    it 'returns a response struct' do
      stub(:get, "#{base_url}/v3/#{domain}/complaints")

      expect(client.get_complaints).to eq(response_struct)
    end

    it 'encodes skip and limit parameters' do
      stub(:get, "#{base_url}/v3/#{domain}/complaints?skip=1&limit=2")

      client.get_complaints(skip: 1, limit: 2)
    end
  end

  describe '#get_complaint' do
    it 'returns a response struct' do
      stub(:get, "#{base_url}/v3/#{domain}/complaints/#{encoded_address}")

      expect(client.get_complaint(address)).to eq(response_struct)
    end
  end

  describe '#add_complaint' do
    it 'returns a response struct' do
      stub(:post, "#{base_url}/v3/#{domain}/complaints", body: "address=#{encoded_address}")

      expect(client.add_complaint(address: address)).to eq(response_struct)
    end
  end

  describe '#delete_complaint' do
    it 'returns a response struct' do
      stub(:delete, "#{base_url}/v3/#{domain}/complaints/#{encoded_address}")

      expect(client.delete_complaint(address)).to eq(response_struct)
    end
  end

  describe '#get_bounces' do
    it 'returns a response struct' do
      stub(:get, "#{base_url}/v3/#{domain}/bounces")

      expect(client.get_bounces).to eq(response_struct)
    end

    it 'encodes skip and limit parameters' do
      stub(:get, "#{base_url}/v3/#{domain}/bounces?skip=1&limit=2")

      client.get_bounces(skip: 1, limit: 2)
    end
  end

  describe '#get_bounce' do
    it 'returns a response struct' do
      stub(:get, "#{base_url}/v3/#{domain}/bounces/#{encoded_address}")

      expect(client.get_bounce(address)).to eq(response_struct)
    end
  end

  describe '#add_bounce' do
    it 'returns a response struct' do
      stub(:post, "#{base_url}/v3/#{domain}/bounces", body: "address=#{encoded_address}")

      expect(client.add_bounce(address: address)).to eq(response_struct)
    end
  end

  describe '#delete_bounce' do
    it 'returns a response struct' do
      stub(:delete, "#{base_url}/v3/#{domain}/bounces/#{encoded_address}")

      expect(client.delete_bounce(address)).to eq(response_struct)
    end
  end

  describe '#delete_bounces' do
    it 'returns a response struct' do
      stub(:delete, "#{base_url}/v3/#{domain}/bounces")

      expect(client.delete_bounces).to eq(response_struct)
    end
  end

  describe '#get_whitelists' do
    it 'returns a response struct' do
      stub(:get, "#{base_url}/v3/#{domain}/whitelists")

      expect(client.get_whitelists).to eq(response_struct)
    end
  end

  describe '#get_whitelist' do
    it 'returns a response struct' do
      stub(:get, "#{base_url}/v3/#{domain}/whitelists/#{encoded_address}")

      expect(client.get_whitelist(address)).to eq(response_struct)
    end
  end

  describe '#add_whitelist' do
    it 'returns a response struct' do
      stub(:post, "#{base_url}/v3/#{domain}/whitelists", body: "address=#{encoded_address}")

      expect(client.add_whitelist(address: address)).to eq(response_struct)
    end
  end

  describe '#delete_whitelist' do
    it 'returns a response struct' do
      stub(:delete, "#{base_url}/v3/#{domain}/whitelists/#{encoded_address}")

      expect(client.delete_whitelist(address)).to eq(response_struct)
    end
  end

  describe '#get_total_stats' do
    it 'returns a response struct' do
      stub(:get, "#{base_url}/v3/#{domain}/stats/total?event=delivered")

      expect(client.get_total_stats(event: 'delivered')).to eq(response_struct)
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

  describe '#get_events' do
    it 'returns a response struct' do
      stub(:get, "#{base_url}/v3/#{domain}/events")

      expect(client.get_events).to eq(response_struct)
    end

    it 'encodes optional parameters' do
      stub(:get, "#{base_url}/v3/#{domain}/events?event=accepted&limit=10")

      client.get_events(event: 'accepted', limit: 10)
    end
  end

  describe '#get_tags' do
    it 'returns a response struct' do
      stub(:get, "#{base_url}/v3/#{domain}/tags")

      expect(client.get_tags).to eq(response_struct)
    end

    it 'encodes optional limit parameter' do
      stub(:get, "#{base_url}/v3/#{domain}/tags?limit=2")

      client.get_tags(limit: 2)
    end
  end

  describe '#get_tag' do
    it 'returns a response struct' do
      stub(:get, "#{base_url}/v3/#{domain}/tags/#{id}")

      expect(client.get_tag(id)).to eq(response_struct)
    end
  end

  describe '#update_tag' do
    it 'returns a response struct' do
      stub(:put, "#{base_url}/v3/#{domain}/tags/#{id}", body: 'description=Tag+description')

      expect(client.update_tag(id, {description: 'Tag description'})).to eq(response_struct)
    end
  end

  describe '#get_tag_stats' do
    it 'returns a response struct' do
      stub(:get, "#{base_url}/v3/#{domain}/tags/#{id}/stats?event=accepted")

      expect(client.get_tag_stats(id, event: 'accepted')).to eq(response_struct)
    end
  end

  describe '#delete_tag' do
    it 'returns a response struct' do
      stub(:delete, "#{base_url}/v3/#{domain}/tags/#{id}")

      expect(client.delete_tag(id)).to eq(response_struct)
    end
  end

  describe '#get_routes' do
    it 'returns a response struct' do
      stub(:get, "#{base_url}/v3/routes")

      expect(client.get_routes).to eq(response_struct)
    end

    it 'encodes skip and limit parameters' do
      stub(:get, "#{base_url}/v3/routes?skip=1&limit=2")

      client.get_routes(skip: 1, limit: 2)
    end
  end

  describe '#get_route' do
    it 'returns a response struct' do
      stub(:get, "#{base_url}/v3/routes/#{id}")

      expect(client.get_route(id)).to eq(response_struct)
    end
  end

  describe '#add_route' do
    it 'returns a response struct' do
      stub(:post, "#{base_url}/v3/routes", body: 'description=Example+route&priority=1')

      expect(client.add_route({description: 'Example route', priority: 1})).to eq(response_struct)
    end
  end

  describe '#update_route' do
    it 'returns a response struct' do
      stub(:put, "#{base_url}/v3/routes/#{id}", body: 'priority=10')

      expect(client.update_route(id, {priority: 10})).to eq(response_struct)
    end
  end

  describe '#delete_route' do
    it 'returns a response struct' do
      stub(:delete, "#{base_url}/v3/routes/#{id}")

      expect(client.delete_route(id)).to eq(response_struct)
    end
  end

  describe '#get_webhooks' do
    it 'returns a response struct' do
      stub(:get, "#{base_url}/v3/domains/#{domain}/webhooks")

      expect(client.get_webhooks).to eq(response_struct)
    end
  end

  describe '#get_webhook' do
    it 'returns a response struct' do
      stub(:get, "#{base_url}/v3/domains/#{domain}/webhooks/#{id}")

      expect(client.get_webhook(id)).to eq(response_struct)
    end
  end

  describe '#add_webhook' do
    it 'returns a response struct' do
      attributes = {id: id, url: 'http://example.com/webhook'}

      stub(:post, "#{base_url}/v3/domains/#{domain}/webhooks", body: attributes)

      expect(client.add_webhook(attributes)).to eq(response_struct)
    end
  end

  describe '#update_webhook' do
    it 'returns a response struct' do
      attributes = {url: 'http://example.com/webhook'}

      stub(:put, "#{base_url}/v3/domains/#{domain}/webhooks/#{id}", body: attributes)

      expect(client.update_webhook(id, attributes)).to eq(response_struct)
    end
  end

  describe '#delete_webhook' do
    it 'returns a response struct' do
      stub(:delete, "#{base_url}/v3/domains/#{domain}/webhooks/#{id}")

      expect(client.delete_webhook(id)).to eq(response_struct)
    end
  end

  describe '#get_all_ips' do
    it 'returns a response struct' do
      stub(:get, "#{base_url}/v3/ips")

      expect(client.get_all_ips).to eq(response_struct)
    end
  end

  describe '#get_ip' do
    it 'returns a response struct' do
      address = '127.0.0.1'

      stub(:get, "#{base_url}/v3/ips/#{address}")

      expect(client.get_ip(address)).to eq(response_struct)
    end
  end

  describe '#get_ips' do
    it 'returns a response struct' do
      stub(:get, "#{base_url}/v3/domains/#{domain}/ips")

      expect(client.get_ips).to eq(response_struct)
    end
  end

  describe '#add_ip' do
    it 'returns a response struct' do
      address = '127.0.0.1'

      stub(:post, "#{base_url}/v3/domains/#{domain}/ips", body: {ip: address})

      expect(client.add_ip(address)).to eq(response_struct)
    end
  end

  describe '#delete_ip' do
    it 'returns a response struct' do
      address = '127.0.0.1'

      stub(:delete, "#{base_url}/v3/domains/#{domain}/ips/#{address}")

      expect(client.delete_ip(address)).to eq(response_struct)
    end
  end

  describe '#get_lists' do
    it 'returns a response struct' do
      stub(:get, "#{base_url}/v3/lists/pages")

      expect(client.get_lists).to eq(response_struct)
    end

    it 'encodes skip and limit parameters' do
      stub(:get, "#{base_url}/v3/lists/pages?skip=1&limit=2")

      client.get_lists(skip: 1, limit: 2)
    end
  end

  describe '#get_list' do
    it 'returns a response struct' do
      stub(:get, "#{base_url}/v3/lists/developers%40mailgun.net")

      expect(client.get_list(list_address)).to eq(response_struct)
    end
  end

  describe '#add_list' do
    it 'returns a response struct' do
      stub(:post, "#{base_url}/v3/lists", body: 'address=developers%40mailgun.net')

      expect(client.add_list(address: list_address)).to eq(response_struct)
    end
  end

  describe '#update_list' do
    it 'returns a response struct' do
      stub(:put, "#{base_url}/v3/lists/developers%40mailgun.net", body: 'name=Example+list')

      expect(client.update_list(list_address, {name: 'Example list'})).to eq(response_struct)
    end
  end

  describe '#delete_list' do
    it 'returns a response struct' do
      stub(:delete, "#{base_url}/v3/lists/developers%40mailgun.net")

      expect(client.delete_list(list_address)).to eq(response_struct)
    end
  end

  describe '#get_list_members' do
    it 'returns a response struct' do
      stub(:get, "#{base_url}/v3/lists/developers%40mailgun.net/members/pages")

      expect(client.get_list_members(list_address)).to eq(response_struct)
    end

    it 'encodes skip and limit parameters' do
      stub(:get, "#{base_url}/v3/lists/developers%40mailgun.net/members/pages?skip=1&limit=2")

      client.get_list_members(list_address, skip: 1, limit: 2)
    end
  end

  describe '#get_list_member' do
    it 'returns a response struct' do
      stub(:get, "#{base_url}/v3/lists/developers%40mailgun.net/members/#{encoded_address}")

      expect(client.get_list_member(list_address, address)).to eq(response_struct)
    end
  end

  describe '#add_list_member' do
    it 'returns a response struct' do
      stub(:post, "#{base_url}/v3/lists/developers%40mailgun.net/members", body: "address=#{encoded_address}")

      expect(client.add_list_member(list_address, address: address)).to eq(response_struct)
    end
  end

  describe '#update_list_member' do
    it 'returns a response struct' do
      stub(:put, "#{base_url}/v3/lists/developers%40mailgun.net/members/#{encoded_address}", body: 'subscribed=no')

      expect(client.update_list_member(list_address, address, {subscribed: 'no'})).to eq(response_struct)
    end
  end

  describe '#delete_list_member' do
    it 'returns a response struct' do
      stub(:delete, "#{base_url}/v3/lists/developers%40mailgun.net/members/#{encoded_address}")

      expect(client.delete_list_member(list_address, address)).to eq(response_struct)
    end
  end
end
