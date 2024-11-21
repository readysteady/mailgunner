require 'spec_helper'

RSpec.describe Mailgunner::Params do
  describe '.encode' do
    it 'returns a string' do
      expect(subject.encode({address: 'user@example.com'})).to eq('address=user%40example.com')
      expect(subject.encode({name: 'Example list'})).to eq('name=Example%20list')
      expect(subject.encode({limit: 10})).to eq('limit=10')
    end
  end
end
