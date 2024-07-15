class Game < ApplicationRecord
  has_many :game_users, dependent: :destroy
  has_many :users, through: :game_users

  validates :name, presence: true
  validates :number_of_players, presence: true, numericality: { only_integer: true, greater_than: 1 }

  def queue_full?
    users.count == number_of_players
  end

  def started?
    !go_fish.nil?
  end

  def over?
    !go_fish.winners.nil?
  end

  serialize :go_fish, coder: GoFish

  def start!
    return false unless queue_full?
    return false if started?

    players = users.map { |user| Player.new(user.id, user.name) }
    go_fish = GoFish.new(players)
    go_fish.deal!
    update(go_fish:, started_at: DateTime.current)
  end

  def play_round!(opponent_id = nil, rank = nil, requester = nil) # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
    raise UnplayableError unless started?
    raise UnplayableError if over?
    raise ParamsRequiredError if opponent_id.nil? || rank.nil? || requester.nil?

    opponent = go_fish.match_player_id(opponent_id)
    chosen_rank = go_fish.validate_rank(rank)
    raise InvalidOpponentError unless opponent
    raise InvalidRankError unless chosen_rank
    raise InvalidRequesterError unless go_fish.validate_requester(requester.id)

    go_fish.play_round!(opponent, rank)
    save!
  end

  # custom exceptions
  class UnplayableError < StandardError
    def message
      'The game cannot currently be played as requested...'
    end
  end

  class ParamsRequiredError < StandardError
    def message
      'You need to enter values to play a round...'
    end
  end

  class InvalidOpponentError < StandardError
    def message
      'The opponent you entered is not valid!'
    end
  end

  class InvalidRankError < StandardError
    def message
      'The rank you entered is not valid!'
    end
  end

  class InvalidRequesterError < StandardError
    def message
      'It is not your turn yet!'
    end
  end
end
