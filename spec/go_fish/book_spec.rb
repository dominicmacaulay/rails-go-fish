require 'rails_helper'

RSpec.describe Book do
  context '#from_json' do
    let(:book) { Book.new(make_card_set('4')) }
    let(:json) do
      { 'cards' => [{ 'rank' => '4', 'suit' => 'Spades' }, { 'rank' => '4', 'suit' => 'Clubs' },
     { 'rank' => '4', 'suit' => 'Diamonds' }, { 'rank' => '4', 'suit' => 'Hearts' }] }
    end

    it 'returns a book object with all the information' do
      new_book = Book.from_json(json)
      second_new_book = Book.from_json(json)
      expect(new_book).to eq second_new_book
      expect(new_book).to eq book
    end
  end

  context '#==' do
    let(:cards) { make_card_set('4') }
    let(:book) { Book.new(cards) }
    it 'returns true when the book attributes are equal' do
      other_book = Book.new(cards)
      expect(book).to eq other_book
    end

    it 'returns true even if the cards are in a different order' do
      other_book = Book.new(cards.reverse)
      expect(book).to eq other_book
    end

    it 'returns false when the book attributes are not equal' do
      other_book = Book.new(make_card_set('5'))
      expect(book).not_to eq other_book
    end
  end
end

def make_card_set(rank)
  [Card.new(rank, 'Spades'), Card.new(rank, 'Clubs'), Card.new(rank, 'Diamonds'), Card.new(rank, 'Hearts')]
end
