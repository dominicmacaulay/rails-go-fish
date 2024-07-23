class Leaderboard < ApplicationRecord
  self.primary_key = :user_id

  def winning_rate
    "#{(win_rate * 100).round(0)}%"
  end

  def time
    "#{(total_time_played / 3600).round(2)} hours"
  end

  def readonly?
    true
  end
end
