# frozen_string_literal: false

# class for Go fish
class GoFish # rubocop:disable Metrics/ClassLength
  DEAL_NUMBER = 5
  MINIMUM_BOOK_LENGTH = 4

  attr_reader :players, :deck, :round_results
  attr_accessor :current_player, :winners, :rounds_played

  def initialize(players, current_player: players.first, deck: Deck.new, rounds_played: 0, round_results: [], # rubocop:disable Metrics/ParameterLists
                 winners: nil)
    @players = players
    @current_player = current_player
    @deck = deck
    @rounds_played = rounds_played
    @round_results = round_results
    @winners = winners
  end

  def score_board
    if winners.nil?
      generate_score_board(players)
    else
      generate_score_board(winners)
    end
  end

  def deal!
    deck.shuffle
    DEAL_NUMBER.times do
      players.each { |player| player.add_to_hand(deck.deal) }
    end
  end

  def play_round!(opponent_id, rank, requester)
    opponent = validate_input_and_find_opponent(opponent_id, rank, requester)
    message = run_transaction(opponent, rank)
    message.book_was_made if current_player.make_book?
    switch_player unless message.got_rank
    post_round_actions(message)
  end

  def display_winners
    GameResult.new(winners)
  end

  def check_for_winners
    return unless players.map(&:hand_count).sum.zero? && deck.cards.empty?

    self.winners = determine_winners
    self.rounds_played = "#{rounds_played} (finished)"
  end

  def switch_player
    index = players.index(current_player)
    self.current_player = players[(index + 1) % players.count]
  end

  def ==(other)
    return false unless other

    return false unless players == other.players

    return false unless current_player == other.current_player

    return false unless deck == other.deck

    return false unless rounds_played == other.rounds_played

    return false unless round_results_equal?(other.round_results)

    true
  end

  # custom exceptions
  class GoFishError < StandardError; end

  class ParamsRequiredError < GoFishError
    def message
      'You need to enter values to play a round...'
    end
  end

  class InvalidOpponentError < GoFishError
    def message
      'The opponent you entered is not valid!'
    end
  end

  class InvalidRankError < GoFishError
    def message
      'The rank you entered is not valid!'
    end
  end

  class InvalidRequesterError < GoFishError
    def message
      'It is not your turn yet!'
    end
  end

  # JSON SECTION
  def self.dump(object)
    object.as_json
  end

  def self.load(payload)
    return unless payload

    from_json(payload)
  end

  def self.from_json(json) # rubocop:disable Metrics/AbcSize
    players = json['players'].map { |player| Player.from_json(player) }
    current_player = players.detect { |player| player.id == json['current_player']['id'] }
    deck = Deck.from_json(json['deck'])
    rounds_played = json['rounds_played']
    round_results = hydrate_round_results(json['round_results'])
    winners = json['winners']&.map { |winner| Player.from_json(winner) }
    GoFish.new(players, current_player:, deck:, rounds_played:, round_results:, winners:)
  end

  def self.hydrate_round_results(json)
    if json.nil?
      []
    else
      json.map { |result| RoundResult.from_json(result) }
    end
  end

  def self.hydrate_rounds_played(json)
    if json.include?('finished')
      rounds = json.split
      rounds.first.to_i
      rounds.join(' ')
    else
      json.to_i
    end
  end

  private

  def post_round_actions(message)
    self.rounds_played += 1
    check_for_winners
    change_to_valid_player
    round_results.unshift message
  end

  def change_to_valid_player
    return if winners

    empty_hand = current_player.hand_count.zero?
    while empty_hand
      deal_to_player_if_necessary
      empty_hand = current_player.hand_count.zero?
    end
  end

  def generate_score_board(players)
    score_board = {}
    players.each do |player|
      score_board[player.id] =
        { 'name' => player.name.to_s, 'books_count' => player.book_count.to_s,
          'books_value' => player.total_book_value.to_s }
      score_board[player.id]['winner'] = 'true' unless winners.nil?
    end
    score_board
  end

  def validate_input_and_find_opponent(opponent_id, chosen_rank, requester)
    raise ParamsRequiredError if opponent_id.nil? || chosen_rank.empty? || requester.nil?

    opponent = match_player_id(opponent_id)
    rank = validate_rank(chosen_rank)
    raise InvalidOpponentError unless opponent
    raise InvalidRankError unless rank
    raise InvalidRequesterError unless validate_requester(requester.id)

    opponent
  end

  def match_player_id(id)
    named_player = players.detect do |player|
      player.id == id && player != current_player
    end
    named_player.nil? ? nil : named_player
  end

  def validate_rank(rank)
    current_player.hand_has_rank?(rank)
  end

  def validate_requester(requester_id)
    current_player.id == requester_id
  end

  def next_player
    index = players.index(current_player)
    self.current_player = players[(index + 1) % players.count]
  end

  def run_transaction(opponent, rank)
    return opponent_transaction(opponent, rank) if opponent.hand_has_rank?(rank)
    return pond_transaction(opponent, rank) unless deck.count.zero?

    pond_empty(opponent, rank)
  end

  def opponent_transaction(opponent, rank)
    cards = opponent.remove_cards_with_rank(rank)
    current_player.add_to_hand(cards)
    RoundResult.new(id: (round_results.length + 1), player: current_player, opponent:, rank:, got_rank: true,
                    amount: integer_to_string(cards.count))
  end

  def pond_transaction(opponent, rank)
    card = deck.deal
    current_player.add_to_hand(card)
    if card.equal_rank?(rank)
      RoundResult.new(id: (round_results.length + 1), player: current_player, opponent:, rank:, fished: true,
                      got_rank: true)
    else
      RoundResult.new(id: (round_results.length + 1), player: current_player, opponent:, rank:, fished: true,
                      card_gotten: card.rank)
    end
  end

  def pond_empty(opponent, rank)
    RoundResult.new(id: (round_results.length + 1), player: current_player, opponent:, rank:, fished: true,
                    empty_pond: true)
  end

  def integer_to_string(integer)
    return 'one' if integer == 1
    return 'two' if integer == 2
    return 'three' if integer == 3

    'several'
  end

  def deal_to_player_if_necessary
    return nil unless current_player.hand_count.zero?

    if deck.count.zero?
      switch_player
      return false
    end
    DEAL_NUMBER.times { current_player.add_to_hand(deck.deal) unless deck.count.zero? }
    true
  end

  def determine_winners
    possible_winners = players_with_highest_book_count
    player_with_highest_book_value(possible_winners)
  end

  def player_with_highest_book_value(players)
    maximum_value = 0
    players.each do |player|
      maximum_value = player.total_book_value if player.total_book_value > maximum_value
    end
    players.select { |player| player.total_book_value == maximum_value }
  end

  def players_with_highest_book_count
    maximum_value = 0
    players.each do |player|
      maximum_value = player.book_count if player.book_count > maximum_value
    end
    players.select { |player| player.book_count == maximum_value }
  end

  def round_results_equal?(other)
    return false unless round_results.count == other.count
    return false unless round_results.all? { |result| other.include?(result) }

    true
  end
end
