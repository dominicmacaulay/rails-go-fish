require 'rails_helper'

RSpec.describe GameResult do
  context '#==' do
    let(:winners) { [Player.new('1', 'Player1')] }
    let(:result1) { GameResult.new(winners) }
    it 'returns true when the winners are the same' do
      result2 = GameResult.new(winners)
      expect(result1).to eq result2
    end

    it 'returns false when the winners are different' do
      result2 = GameResult.new([Player.new('2', 'Player2')])
      expect(result1).not_to eq result2
    end
  end

  context '#display_for' do
    let(:winner) { [Player.new('1', 'Player1')] }
    let(:winners) { [Player.new('1', 'Player1'), Player.new('2', 'Player2')] }
    context 'first person messages' do
      let(:session_player) { Player.new('1', 'Player1') }

      it 'shows a first person message when you are the only winner' do
        result = GameResult.new(winner)
        message = 'You won the game with 0 books totalling in 0'
        expect(result.display_for(session_player)).to eq message
      end

      it 'shows a first person message when you are one of many winners' do
        result = GameResult.new(winners)
        message = 'You and Player2 tied with 0 books totalling in 0'
        expect(result.display_for(session_player)).to eq message
      end
    end

    context 'third person messages' do
      let(:session_player) { Player.new('2', 'Player2') }
      it 'shows a third person message when you are the only winner' do
        result = GameResult.new(winner)
        message = 'Player1 won the game with 0 books totalling in 0'
        expect(result.display_for(session_player)).to eq message
      end

      it 'shows a third person message when you are one of many winners' do
        result = GameResult.new(winners)
        message = 'You and Player1 tied with 0 books totalling in 0'
        expect(result.display_for(session_player)).to eq message
      end
    end
  end
end
