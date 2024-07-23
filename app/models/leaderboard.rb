class Leaderboard < ApplicationRecord
  attr_accessor :rank

  self.primary_key = :user_id
  paginates_per 50

  def winning_rate
    "#{(win_rate * 100).round(0)}%"
  end

  def time
    "#{(total_time_played / 3600).round(2)} hours"
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[user_id score user wins losses total_games win_rate total_time_played highest_book_count]
  end

  def readonly?
    true
  end
end
