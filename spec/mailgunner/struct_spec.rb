require 'spec_helper'

RSpec.describe Mailgunner::Struct do
  let(:struct) { Mailgunner::Struct.new }
  let(:description) { 'This is a description' }

  before { struct['description'] = description }

  it 'supports string key access' do
    expect(struct['description']).to eq(description)
  end

  it 'supports symbol key access' do
    expect(struct[:description]).to eq(description)
  end

  it 'supports method call access' do
    expect(struct.description).to eq(description)
  end

  describe '#to_h' do
    it 'returns the attribute hash' do
      expect(struct.to_h).to eq('description' => description)
    end
  end
end
