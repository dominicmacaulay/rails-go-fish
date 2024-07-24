class Game < ApplicationRecord
  has_many :game_users, dependent: :destroy
  has_many :users, through: :game_users

  validates :name, presence: true
  validates :number_of_players, presence: true, numericality: { only_integer: true, greater_than: 1 }

  before_destroy :can_destroy?, prepend: true

  scope :unfinished, -> { order(created_at: :desc).where(over: false) }
  scope :joinable, -> { order(created_at: :desc).where(started: false, over: false) }
  scope :in_progress, -> { order(created_at: :desc).where(started: true, over: false) }
  scope :finished, -> { order(created_at: :desc).where(over: true) }

  after_create_commit -> { broadcast_refresh_to 'games' }
  after_update_commit -> { broadcast_refresh_to 'games' }
  after_destroy_commit -> { broadcast_refresh_to 'games' }
  # broadcasts_refreshes

  def self.ransackable_attributes(auth_object = nil)
    %w[name]
  end

  def run_time
    return unless finished_at

    seconds_played = finished_at - started_at

    if seconds_played >= Leaderboard::SECONDS_TO_HOURS_FACTOR
      hours = (seconds_played / Leaderboard::SECONDS_TO_HOURS_FACTOR).to_i
      minutes = ((seconds_played % Leaderboard::SECONDS_TO_HOURS_FACTOR) / Leaderboard::SECONDS_TO_MINUTES_FACTOR).to_i
      "#{hours}h #{minutes}m"
    elsif seconds_played >= Leaderboard::SECONDS_TO_MINUTES_FACTOR
      minutes = (seconds_played / Leaderboard::SECONDS_TO_MINUTES_FACTOR).to_i
      remaining_seconds = (seconds_played % Leaderboard::SECONDS_TO_MINUTES_FACTOR).to_i
      "#{minutes}m #{remaining_seconds}s"
    else
      "#{seconds_played.to_i}s"
    end
  end

  def queue_full?
    users.count == number_of_players
  end

  def started
    !go_fish.nil?
  end

  def over
    return false if go_fish.nil?

    !go_fish.winners.nil?
  end

  def can_destroy?
    return true unless started
    return true if over

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
    update_views
    return false unless queue_full?
    return false if started

    players = users.map { |user| Player.new(user.id, user.name) }
    go_fish = GoFish.new(players)
    go_fish.deal!
    update(go_fish:, started_at: DateTime.current, started: true)
    update_views
  end

  def play_round!(opponent_id = nil, rank = nil, requester = nil)
    raise UnplayableError unless started
    raise UnplayableError if over

    go_fish.play_round!(opponent_id, rank, requester)
    end_game(go_fish) if go_fish.winners
    save!
    # update(over: true, finished_at: DateTime.current) if go_fish.winners
    update_views
  end

  def update_views
    users.each { |user| broadcast_refresh_to "games:#{id}:users:#{user.id}" }
    broadcast_refresh_to 'game_status'
    broadcast_refresh_to 'game_history'
    broadcast_refresh_to 'leaderboard'
    broadcast_refresh_to 'spectate'
  end

  def end_game(go_fish)
    self.over = true
    self.finished_at = DateTime.current
    update_game_users(go_fish)
  end

  class GameError < StandardError; end

  class UnplayableError < GameError
    def message
      'The game cannot currently be played as requested...'
    end
  end

  private

  def update_game_users(go_fish)
    winners = go_fish.winners
    game_users.each do |game_user|
      game_user.winner = winners.any? { |winner| winner.id == game_user.user_id }
      game_user.books = go_fish.players.detect { |player| player.id == game_user.user_id }.book_count
      game_user.book_value = go_fish.players.detect { |player| player.id == game_user.user_id }.total_book_value
      game_user.save!
    end
  end
end
