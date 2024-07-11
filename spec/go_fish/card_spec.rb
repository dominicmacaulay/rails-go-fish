require 'rails_helper'

RSpec.describe Card do
  context '#from_json' do
    let(:card) { Card.new('4', 'Spades') }
    let(:json) { { 'rank' => '4', 'suit' => 'Spades' } }

    it 'returns a card object with all of the information passed in' do
      new_card = Card.from_json(json)
      second_new_card = Card.from_json(json)
      expect(new_card).to eq second_new_card
      expect(new_card).to eq card
    end
  end
end
