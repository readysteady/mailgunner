require 'minitest/autorun'
require 'mailgunner'

describe 'Mailgunner::Struct' do
  let(:struct) { Mailgunner::Struct.new }
  let(:description) { 'This is a description' }

  before do
    struct['description'] = description
  end

  it 'supports string key access' do
    struct['description'].must_equal(description)
  end

  it 'supports symbol key access' do
    struct[:description].must_equal(description)
  end

  it 'supports method call access' do
    struct.description.must_equal(description)
  end

  describe 'to_h method' do
    it 'returns the attribute hash' do
      struct.to_h.must_equal('description' => description)
    end
  end
end
