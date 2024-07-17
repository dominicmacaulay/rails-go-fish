class Game < ApplicationRecord
  has_many :game_users, dependent: :destroy
  has_many :users, through: :game_users

  validates :name, presence: true
  validates :number_of_players, presence: true, numericality: { only_integer: true, greater_than: 1 }

  after_update_commit lambda {
                        users.each do |user|
                          broadcast_update_to "#{user.id}_#{id}", partial: 'games/game_play',
                                                                  locals: { game: self, current_user: user }
                        end
                      }

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
    update(users:)
    return false unless queue_full?
    return false if started?

    players = users.map { |user| Player.new(user.id, user.name) }
    go_fish = GoFish.new(players)
    go_fish.deal!
    update(go_fish:, started_at: DateTime.current)
  end

  def play_round!(opponent_id = nil, rank = nil, requester = nil)
    raise UnplayableError unless started?
    raise UnplayableError if over?

    go_fish.play_round!(opponent_id, rank, requester)
    save!
  end

  class GameError < StandardError; end

  class UnplayableError < GameError
    def message
      'The game cannot currently be played as requested...'
    end
  end
end
