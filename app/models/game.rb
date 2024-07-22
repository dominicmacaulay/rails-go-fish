class Game < ApplicationRecord
  has_many :game_users, dependent: :destroy
  has_many :users, through: :game_users

  validates :name, presence: true
  validates :number_of_players, presence: true, numericality: { only_integer: true, greater_than: 1 }

  before_destroy :can_destroy?, prepend: true

  after_create_commit -> { broadcast_refresh_to 'games' }
  after_update_commit -> { broadcast_refresh_to 'games' }
  after_destroy_commit -> { broadcast_refresh_to 'games' }
  # broadcasts_refreshes

  def queue_full?
    users.count == number_of_players
  end

  def started?
    !go_fish.nil?
  end

  def over?
    return false if go_fish.nil?

    !go_fish.winners.nil?
  end

  def can_destroy?
    return true unless started?
    return true if over?

    false
  end

  delegate :rounds_played, to: :go_fish
  delegate :score_board, to: :go_fish

  def score_board
    players_hash = go_fish.score_board
    players_hash.map do |_player, info|
      "#{info['name']} books: #{info['books_count']}, total score: #{info['books_value']}"
    end
  end

  serialize :go_fish, coder: GoFish

  def start!
    update(users:)
    update_show
    return false unless queue_full?
    return false if started?

    players = users.map { |user| Player.new(user.id, user.first_name) }
    go_fish = GoFish.new(players)
    go_fish.deal!
    update(go_fish:, started_at: DateTime.current)
    update_show
  end

  def play_round!(opponent_id = nil, rank = nil, requester = nil)
    raise UnplayableError unless started?
    raise UnplayableError if over?

    go_fish.play_round!(opponent_id, rank, requester)
    save!
    update_show
  end

  def update_show
    users.each { |user| broadcast_refresh_to "games:#{id}:users:#{user.id}" }
  end

  class GameError < StandardError; end

  class UnplayableError < GameError
    def message
      'The game cannot currently be played as requested...'
    end
  end
end
