require 'rails_helper'

RSpec.describe RoundResult do
  let(:player1) { Player.new(1, 'P1') }
  let(:player2) { Player.new(2, 'P2') }
  let(:player3) { Player.new(3, 'P3') }

  # TODO: write serialization tests for this
  context '#==' do
    it 'returns true if the stored strings are the same' do
      result1 = RoundResult.new(player: player1, opponent: player2, rank: '2', fished: false, got_rank: true,
                                card_gotten: '2', amount: 'two', empty_pond: true)
      result2 = RoundResult.new(player: player1, opponent: player2, rank: '2', fished: false, got_rank: true,
                                card_gotten: '2', amount: 'two', empty_pond: true)
      expect(result1).to eq result2
    end
    it 'returns false if the stored string are not the same' do
      result1 = RoundResult.new(player: player1, opponent: player2, rank: '2')
      result2 = RoundResult.new(player: player3, opponent: player2, rank: '2')
      expect(result1).not_to eq result2
    end
  end

  context '#display' do
    context 'for the current_player' do
      it 'gets rank from opponent' do
        result = RoundResult.new(player: player1, opponent: player2, rank: '2', got_rank: true, amount: 'two')

        result_message = result.generate_message_for(player1)

        expect(result_message.action).to eql "You asked P2 for 2's"
        expect(result_message.opponent_response).to eql "P2 had 2's"
        expect(result_message.result).to eql 'You got two of them'
      end
      it 'gets rank from pond' do
        result = RoundResult.new(player: player1, opponent: player2, rank: '2', fished: true, got_rank: true)
        result_message = result.generate_message_for(player1)
        expect(result_message.action).to eql "You asked P2 for 2's"
        expect(result_message.opponent_response).to eql "Go Fish! P2 did not have any 2's"
        expect(result_message.result).to eql 'You got one of them'
      end
      it 'does not get rank from the pond' do
        result = RoundResult.new(player: player1, opponent: player2, rank: '2', fished: true, card_gotten: '4')
        result_message = result.generate_message_for(player1)
        expect(result_message.action).to eql "You asked P2 for 2's"
        expect(result_message.opponent_response).to eql "Go Fish! P2 did not have any 2's"
        expect(result_message.result).to eql 'You got a 4'
      end
      it 'does not get anything' do
        result = RoundResult.new(player: player1, opponent: player2, rank: '2', fished: true, empty_pond: true)
        result_message = result.generate_message_for(player1)
        expect(result_message.action).to eql "You asked P2 for 2's"
        expect(result_message.opponent_response).to eql "Go Fish! P2 did not have any 2's"
        expect(result_message.result).to eql 'You got nothing for the pond is empty'
      end
    end

    context 'for the opponent' do
      it 'gets rank from opponent' do
        # given
        result = RoundResult.new(player: player1, opponent: player2, rank: '2', got_rank: true, amount: 'two')
        # when
        result_message = result.generate_message_for(player2)
        # then
        expect(result_message.action).to eql "P1 asked you for 2's"
        expect(result_message.opponent_response).to eql "You had 2's"
        expect(result_message.result).to eql 'P1 got two of them'
      end
      it 'gets rank from pond' do
        result = RoundResult.new(player: player1, opponent: player2, rank: '2', fished: true, got_rank: true)
        result_message = result.generate_message_for(player2)
        expect(result_message.action).to eql "P1 asked you for 2's"
        expect(result_message.opponent_response).to eql "Go Fish! You did not have any 2's"
        expect(result_message.result).to eql 'P1 got one of them'
      end
      it 'does not get rank from the pond' do
        result = RoundResult.new(player: player1, opponent: player2, rank: '2', fished: true, card_gotten: '4')
        result_message = result.generate_message_for(player2)
        expect(result_message.action).to eql "P1 asked you for 2's"
        expect(result_message.opponent_response).to eql "Go Fish! You did not have any 2's"
        expect(result_message.result).to eql 'P1 had no luck'
      end
      it 'does not get anything' do
        result = RoundResult.new(player: player1, opponent: player2, rank: '2', fished: true, empty_pond: true)
        result_message = result.generate_message_for(player2)
        expect(result_message.action).to eql "P1 asked you for 2's"
        expect(result_message.opponent_response).to eql "Go Fish! You did not have any 2's"
        expect(result_message.result).to eql 'P1 got nothing for the pond is empty'
      end
    end

    context 'for any other players' do
      it 'gets rank from opponent' do
        # given
        result = RoundResult.new(player: player1, opponent: player2, rank: '2', got_rank: true, amount: 'two')
        # when
        result_message = result.generate_message_for(player3)
        # then
        expect(result_message.action).to eql "P1 asked P2 for 2's"
        expect(result_message.opponent_response).to eql "P2 had 2's"
        expect(result_message.result).to eql 'P1 got two of them'
      end
      it 'gets rank from pond' do
        result = RoundResult.new(player: player1, opponent: player2, rank: '2', fished: true, got_rank: true)
        result_message = result.generate_message_for(player3)
        expect(result_message.action).to eql "P1 asked P2 for 2's"
        expect(result_message.opponent_response).to eql "Go Fish! P2 did not have any 2's"
        expect(result_message.result).to eql 'P1 got one of them'
      end
      it 'does not get rank from the pond' do
        result = RoundResult.new(player: player1, opponent: player2, rank: '2', fished: true, card_gotten: '4')
        result_message = result.generate_message_for(player3)
        expect(result_message.action).to eql "P1 asked P2 for 2's"
        expect(result_message.opponent_response).to eql "Go Fish! P2 did not have any 2's"
        expect(result_message.result).to eql 'P1 had no luck'
      end
      it 'does not get anything' do
        result = RoundResult.new(player: player1, opponent: player2, rank: '2', fished: true, empty_pond: true)
        result_message = result.generate_message_for(player3)
        expect(result_message.action).to eql "P1 asked P2 for 2's"
        expect(result_message.opponent_response).to eql "Go Fish! P2 did not have any 2's"
        expect(result_message.result).to eql 'P1 got nothing for the pond is empty'
      end
    end

    context 'concats the books made message if its true' do
      it 'does not concat if variable is false' do
        # given
        result = RoundResult.new(player: player1, opponent: player2, rank: '2', got_rank: true, amount: 'two')
        # when
        result_message = result.generate_message_for(player1)
        # then
        expect(result_message.result).to eql 'You got two of them'
      end
      it 'does concat if varialbe is true' do
        # given
        result = RoundResult.new(player: player1, opponent: player2, rank: '2', got_rank: true, amount: 'two')
        result.book_was_made
        # when
        result_message = result.generate_message_for(player1)
        # then
        expect(result_message.result).to eql 'You got two of them and created a book with them'
      end
    end
  end
end
