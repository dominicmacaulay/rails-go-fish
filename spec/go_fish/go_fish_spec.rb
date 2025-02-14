require 'rails_helper'

RSpec.describe GoFish do
  context 'serialization' do
    let(:players) { create_players(2) }
    let(:go_fish) { GoFish.new(players, round_results: create_round_results(2, players)) }
    let(:json) { go_fish_json }

    it 'converts the passed json into an object' do
      new_go_fish = GoFish.from_json(json)
      second_new_go_fish = GoFish.from_json(json)
      expect(new_go_fish).to eq second_new_go_fish
      expect(new_go_fish).to eq go_fish
    end

    it 'returns nil if the parameter is nil' do
      expect(GoFish.dump(nil)).to be nil
      expect(GoFish.load(nil)).to be nil
    end
  end

  context '#==' do
    let(:players) { create_players(3) }
    let(:deck) { Deck.new(make_card_set('4')) }
    let(:game) { GoFish.new(players, deck:) }

    it 'returns true when the games are equal' do
      new_game = GoFish.new(create_players(3), deck:)
      expect(game).to eq new_game
    end

    context 'when games are not equal' do
      it 'returns false when the players arrays are not equal' do
        players = create_players(4)
        game_with_different_players = GoFish.new(players.last(3), current_player: game.current_player, deck:)
        game_with_different_ordered_players = GoFish.new(players.first(3).reverse, current_player: game.current_player,
                                                                                   deck:)
        expect(game).not_to eq game_with_different_players
        expect(game).not_to eq game_with_different_ordered_players
      end

      it 'returns false when the current players are not equal' do
        game_with_different_current_player = GoFish.new(players, current_player: players.last, deck:)
        expect(game).not_to eq game_with_different_current_player
      end

      it 'returns false whent the decks are not equal' do
        game_with_different_deck = GoFish.new(players, deck: Deck.new(make_card_set('6')))
        expect(game).not_to eq game_with_different_deck
      end
    end
  end

  context 'game play' do
    let(:players) { create_players(2) }
    let(:player1) { players.first }
    let(:player2) { players.last }
    let(:go_fish) { GoFish.new([player1, player2]) }

    context '#deal!' do
      it 'each player receives cards' do
        go_fish.deal!
        count_equal = players.all? { |player| player.hand_count == GoFish::DEAL_NUMBER }
        expect(count_equal).to be true
      end
    end

    context '#switch_player' do
      it 'switches players' do
        players = create_players(2)
        game = GoFish.new(players)
        expect(game.current_player).to eql players.first
        game.switch_player
        expect(game.current_player).to eql players.last
      end
    end

    context '#score_board' do
      it "returns a hash with each player's name, book count, and book value when there are no winners" do
        response = { 1 => { 'name' => 'Player 1', 'books_count' => '0', 'books_value' => '0' },
                     2 => { 'name' => 'Player 2', 'books_count' => '0', 'books_value' => '0' } }
        expect(go_fish.score_board).to eq response
      end
      it "returns a hash with all the winner's info when there are winners" do
        go_fish.winners = [players.first]
        response = { 1 => { 'winner' => 'true', 'name' => 'Player 1', 'books_count' => '0',
                            'books_value' => '0' } }
        expect(go_fish.score_board).to eq response
        expect(go_fish.score_board['Player 2']).to be nil
      end
    end

    context 'dealing to the player if necessary' do
      before do
        players.each(&:clear)
        go_fish.deck.clear
        go_fish.deck.cards = [*make_card_set('3'), *make_card_set('5')]
        player1.add_to_hand(Card.new('4', 'Hearts'))
      end

      it 'deals to the player the card was asked from if they do not have any cards left' do
        go_fish.play_round!(player2.id, '4', player1)
        expect(player2.hand.count).to eql 5
      end

      it 'changes the player to the player after the next one if the next one still does not have any cards' do
        go_fish.deck.clear
        go_fish.deck.cards = [Card.new('3', 'Hearts')]
        go_fish.play_round!(player2.id, '4', player1)
        expect(player2.hand.count).to eql 0
        expect(go_fish.current_player).to eq player1
      end
    end

    context 'play_round!' do
      before do
        player1.add_to_hand(Card.new('4', 'Hearts'))
      end
      context 'runs transaction when opponent has the card' do
        before do
          player2.add_to_hand(Card.new('4', 'Spades'))
        end
        it 'take the card from the opponent and gives it to the player' do
          go_fish.play_round!(player2.id, '4', player1)
          expect(player2.hand_has_rank?('4')).to be false
          expect(player1.rank_count('4')).to be 2
        end
        it 'returns object' do
          go_fish.play_round!(player2.id, '4', player1)
          object = RoundResult.new(id: 1, player: player1, opponent: player2, rank: '4', got_rank: true, amount: 'one')
          expect(go_fish.round_results.first).to eq object
          expect(go_fish.round_results.count).to eql 1
        end
        it 'updates the round count' do
          expect(go_fish.rounds_played).to eql 0
          go_fish.play_round!(player2.id, '4', player1)
          expect(go_fish.rounds_played).to eql 1
        end
      end

      context 'runs transaction if the pond has no cards in it' do
        it 'sends the player a message saying that the pond was empty' do
          go_fish.deck.clear
          go_fish.play_round!(player2.id, '4', player1)
          object = RoundResult.new(id: 1, player: player1, opponent: player2, rank: '4', fished: true, empty_pond: true)
          expect(go_fish.round_results.first).to eq object
        end
      end

      context 'runs transaction with the pond' do
        it 'returns message object if the player got the card they wanted and lets them play again' do
          go_fish = GoFish.new([player1, player2], deck: Deck.new([Card.new('4', 'Spades')]))
          go_fish.play_round!(player2.id, '4', player1)
          object = RoundResult.new(id: 1, player: player1, opponent: player2, rank: '4', fished: true, got_rank: true)
          expect(go_fish.round_results.first).to eq object
          go_fish.play_round!(player2.id, '4', player1)
          expect(go_fish.round_results.count).to eql 2
        end
        it 'returns a message object if the player did not get the card they wanted' do
          go_fish = GoFish.new([player1, player2], deck: Deck.new([Card.new('6', 'Spades')]))
          go_fish.play_round!(player2.id, '4', player1)
          object = RoundResult.new(id: 1, player: player1, opponent: player2, rank: '4', fished: true, card_gotten: '6')
          expect(go_fish.round_results.first).to eq object
        end
      end

      context 'creating a book' do
        it 'creates books if possible' do
          player2.add_to_hand([Card.new('4', 'Clubs'), Card.new('4', 'Spades'), Card.new('4', 'Diamonds')])
          go_fish.play_round!(player2.id, '4', player1)
          expect(player1.book_count).to be 1
        end
      end

      context 'switching the player' do
        it 'switches the player after the transactions has occurred if they did not get the card they wanted' do
          go_fish = GoFish.new([player1, player2], deck: Deck.new([Card.new('6', 'Spades')]))
          player2.add_to_hand(Card.new('5', 'Clubs'))
          go_fish.play_round!(player2.id, '4', player1)
          expect(go_fish.current_player).to eql player2
        end

        it 'does not switch players if the player got what they wanted from the opponent' do
          player1.add_to_hand(Card.new('4', 'Spades'))
          player2.add_to_hand(Card.new('4', 'Clubs'))
          go_fish.play_round!(player2.id, '4', player1)
          expect(go_fish.current_player).to eql player1
        end

        it 'does not switch players if the player got what they wanted from the pond' do
          go_fish = GoFish.new([player1, player2], deck: Deck.new([Card.new('4', 'Diamonds')]))
          player1.add_to_hand(Card.new('4', 'Spades'))
          player2.add_to_hand(Card.new('5', 'Clubs'))
          go_fish.play_round!(player2.id, '4', player1)
          expect(go_fish.current_player).to eql player1
        end
      end

      context 'dealing to the player if necessary' do
        before do
          player1.clear
          player2.clear
        end
        it 'switches the player if the player and the deck have no cards' do
          go_fish = GoFish.new([player1, player2])
          player2.add_to_hand([Card.new('4', 'Spades'), Card.new('5', 'Hearts')])
          player1.add_to_hand([Card.new('4', 'Spades'), Card.new('4', 'Spades'), Card.new('4', 'Spades')])
          go_fish.deck.clear
          go_fish.play_round!(player2.id, '4', player1)
          expect(player1.hand_count).to eq 0
          expect(go_fish.current_player).to eql player2
        end

        it "does not increase the player's hand if they already have cards" do
          go_fish = GoFish.new([player1, player2])
          player1.add_to_hand(Card.new('4', 'Hearts'))
          go_fish.play_round!(player2.id, '4', player1)
          expect(player1.hand_count).to eq 2
          expect(go_fish.current_player).to eq player2
        end

        it 'deals cards to the player if they do not have any cards' do
          go_fish = GoFish.new([player1, player2], deck: Deck.new([Card.new('6', 'Spades'), Card.new('7', 'Diamonds')]))
          player1.add_to_hand([Card.new('6', 'Hearts'), Card.new('6', 'Diamonds'), Card.new('6', 'Clubs')])
          go_fish.play_round!(player2.id, '6', player1)
          expect(player1.hand_count).to eq 1
          expect(go_fish.current_player).to eql player1
        end
      end

      context 'checks for winner' do
        let(:books) { make_books(13) }
        it 'declares the winner with the most books' do
          winner = Player.new(1, 'Winner', books: books.shift(7))
          loser = Player.new(2, 'Loser', books: books.shift(6))
          winner_go_fish = GoFish.new([winner, loser], deck: Deck.new([0]))
          winner_go_fish.deck.deal
          winner_go_fish.check_for_winners
          message = GameResult.new(winner_go_fish.winners)
          expect(winner_go_fish.display_winners).to eq message
        end
        it 'in case of a book tie, declares the winner with the highest book value' do
          winner = Player.new(1, 'Winner', books: books.pop(6))
          loser1 = Player.new(2, 'Loser', books: books.shift(6))
          loser2 = Player.new(3, 'Loser', books: books.shift(1))
          winner_go_fish = GoFish.new([winner, loser1, loser2], deck: Deck.new([0]))
          winner_go_fish.deck.deal
          winner_go_fish.check_for_winners
          message = GameResult.new(winner_go_fish.winners)
          expect(winner_go_fish.display_winners).to eq message
        end
        it 'in case of total tie, display tie messge' do
          winner = Player.new(1, 'Winner', books: [books[1], books[3], books[5], books[7], books[9], books[11]])
          loser1 = Player.new(2, 'Loser', books: [books[0], books[2], books[4], books[8], books[10], books[12]])
          loser2 = Player.new(3, 'Loser', books: [books[6]])
          winner_go_fish = GoFish.new([winner, loser1, loser2], deck: Deck.new([0]))
          winner_go_fish.deck.deal
          winner_go_fish.check_for_winners
          message = GameResult.new(winner_go_fish.winners)
          expect(winner_go_fish.display_winners).to eq message
        end
        it 'make the rounds_played variable have an over message' do
          winner = Player.new(1, 'Winner', books: books.shift(7))
          loser = Player.new(2, 'Loser', books: books.shift(6))
          winner_go_fish = GoFish.new([winner, loser], deck: Deck.new([0]))
          count = winner_go_fish.rounds_played
          winner_go_fish.deck.deal
          winner_go_fish.check_for_winners
          expect(winner_go_fish.rounds_played).to eq("#{count} (finished)")
        end
      end
    end
  end

  describe 'smoke test' do
    let(:player1) { Player.new(1, 'Dom') }
    let(:player2) { Player.new(2, 'Micah') }
    let(:player3) { Player.new(3, 'Josh') }
    let(:players) { [player1, player2, player3] }
    it 'plays the game to completion' do
      100.times do
        players.each(&:clear)
        go_fish = GoFish.new(players)
        go_fish.deal!
        until go_fish.winners
          current_index = go_fish.players.index(go_fish.current_player)
          other_player = go_fish.players[(current_index + 1) % go_fish.players.count]
          rank = go_fish.current_player.hand.sample.rank
          # puts "#{go_fish.current_player.name} is asking for #{rank}'s"
          go_fish.play_round!(other_player.id, rank, go_fish.current_player)
          # message = result.generate_message_for(go_fish.players[current_index])
          # puts message.action
          # puts message.opponent_response
          # puts message.result
          # puts '-----------------------------'
          # message = result.generate_message_for(other_player)
          # puts message.action
          # puts message.opponent_response
          # puts message.result
          # puts '-----------------------------'
          # message = result.generate_message_for(go_fish.players[(current_index + 2) % go_fish.players.count])
          # puts message.action
          # puts message.opponent_response
          # puts message.result
          # puts '-----------------------------'
          # puts
          # end
          # final_result = go_fish.display_winners
          # go_fish.players.each do |player|
          #   puts final_result.display_for(player)
        end
      end
    end
  end
end

def make_card_set(rank)
  [Card.new(rank, 'Spades'), Card.new(rank, 'Clubs'), Card.new(rank, 'Diamonds'), Card.new(rank, 'Hearts')]
end

def make_books(times)
  deck = retrieve_one_deck
  books = []
  times.times do
    books.push(Book.new(deck.shift))
  end
  books
end

def retrieve_one_deck
  Card::RANKS.map do |rank|
    Card::SUITS.flat_map do |suit|
      Card.new(rank, suit)
    end
  end
end

def create_players(times)
  x = 1
  players = []

  until x > times
    players << Player.new(x, "Player #{x}")
    x += 1
  end

  players
end

def create_round_results(times, players)
  x = 1
  results = []

  until x > times
    results << RoundResult.new(id: 1, player: players.first, opponent: players.last, rank: '2')
    x += 1
  end

  results
end

def go_fish_json # rubocop:disable Metrics/MethodLength
  { 'players' => [{ 'id' => 1, 'name' => 'Player 1', 'hand' => [], 'books' => [] }, { 'id' => 2, 'name' => 'Player 2', 'hand' => [], 'books' => [] }],
    'current_player' => { 'id' => 1, 'name' => 'Player 1', 'hand' => [], 'books' => [] },
    'rounds_played' => 0,
    'deck' =>
  { 'cards' =>
    [{ 'rank' => '2', 'suit' => 'Spades' },
     { 'rank' => '3', 'suit' => 'Spades' },
     { 'rank' => '4', 'suit' => 'Spades' },
     { 'rank' => '5', 'suit' => 'Spades' },
     { 'rank' => '6', 'suit' => 'Spades' },
     { 'rank' => '7', 'suit' => 'Spades' },
     { 'rank' => '8', 'suit' => 'Spades' },
     { 'rank' => '9', 'suit' => 'Spades' },
     { 'rank' => '10', 'suit' => 'Spades' },
     { 'rank' => 'Jack', 'suit' => 'Spades' },
     { 'rank' => 'Queen', 'suit' => 'Spades' },
     { 'rank' => 'King', 'suit' => 'Spades' },
     { 'rank' => 'Ace', 'suit' => 'Spades' },
     { 'rank' => '2', 'suit' => 'Clubs' },
     { 'rank' => '3', 'suit' => 'Clubs' },
     { 'rank' => '4', 'suit' => 'Clubs' },
     { 'rank' => '5', 'suit' => 'Clubs' },
     { 'rank' => '6', 'suit' => 'Clubs' },
     { 'rank' => '7', 'suit' => 'Clubs' },
     { 'rank' => '8', 'suit' => 'Clubs' },
     { 'rank' => '9', 'suit' => 'Clubs' },
     { 'rank' => '10', 'suit' => 'Clubs' },
     { 'rank' => 'Jack', 'suit' => 'Clubs' },
     { 'rank' => 'Queen', 'suit' => 'Clubs' },
     { 'rank' => 'King', 'suit' => 'Clubs' },
     { 'rank' => 'Ace', 'suit' => 'Clubs' },
     { 'rank' => '2', 'suit' => 'Hearts' },
     { 'rank' => '3', 'suit' => 'Hearts' },
     { 'rank' => '4', 'suit' => 'Hearts' },
     { 'rank' => '5', 'suit' => 'Hearts' },
     { 'rank' => '6', 'suit' => 'Hearts' },
     { 'rank' => '7', 'suit' => 'Hearts' },
     { 'rank' => '8', 'suit' => 'Hearts' },
     { 'rank' => '9', 'suit' => 'Hearts' },
     { 'rank' => '10', 'suit' => 'Hearts' },
     { 'rank' => 'Jack', 'suit' => 'Hearts' },
     { 'rank' => 'Queen', 'suit' => 'Hearts' },
     { 'rank' => 'King', 'suit' => 'Hearts' },
     { 'rank' => 'Ace', 'suit' => 'Hearts' },
     { 'rank' => '2', 'suit' => 'Diamonds' },
     { 'rank' => '3', 'suit' => 'Diamonds' },
     { 'rank' => '4', 'suit' => 'Diamonds' },
     { 'rank' => '5', 'suit' => 'Diamonds' },
     { 'rank' => '6', 'suit' => 'Diamonds' },
     { 'rank' => '7', 'suit' => 'Diamonds' },
     { 'rank' => '8', 'suit' => 'Diamonds' },
     { 'rank' => '9', 'suit' => 'Diamonds' },
     { 'rank' => '10', 'suit' => 'Diamonds' },
     { 'rank' => 'Jack', 'suit' => 'Diamonds' },
     { 'rank' => 'Queen', 'suit' => 'Diamonds' },
     { 'rank' => 'King', 'suit' => 'Diamonds' },
     { 'rank' => 'Ace', 'suit' => 'Diamonds' }] },
    'round_results' =>
  [{ 'current_player' => { 'id' => 1, 'name' => 'Player 1', 'hand' => [], 'books' => [] },
     'opponent' => { 'id' => 2, 'name' => 'Player 2', 'hand' => [], 'books' => [] },
     'rank' => '2',
     'fished' => false,
     'got_rank' => false,
     'card_gotten' => nil,
     'amount' => 'one',
     'empty_pond' => false,
     'book_made' => false },
   { 'current_player' => { 'id' => 1, 'name' => 'Player 1', 'hand' => [], 'books' => [] },
     'opponent' => { 'id' => 2, 'name' => 'Player 2', 'hand' => [], 'books' => [] },
     'rank' => '2',
     'fished' => false,
     'got_rank' => false,
     'card_gotten' => nil,
     'amount' => 'one',
     'empty_pond' => false,
     'book_made' => false }],
    'winners' => nil }
end
