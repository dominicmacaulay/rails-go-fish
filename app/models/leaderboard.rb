class Leaderboard < ApplicationRecord
  SECONDS_TO_HOURS_FACTOR = 3600
  SECONDS_TO_MINUTES_FACTOR = 60

  attr_accessor :rank

  self.primary_key = :user_id
  paginates_per 50

  def winning_rate
    "#{(win_rate * 100).round(0)}%"
  end

  def time
    if total_time_played >= SECONDS_TO_HOURS_FACTOR
      hours = (total_time_played / SECONDS_TO_HOURS_FACTOR).to_i
      minutes = ((total_time_played % SECONDS_TO_HOURS_FACTOR) / SECONDS_TO_MINUTES_FACTOR).to_i
      "#{hours}h #{minutes}m"
    elsif total_time_played >= SECONDS_TO_MINUTES_FACTOR
      minutes = (total_time_played / SECONDS_TO_MINUTES_FACTOR).to_i
      remaining_seconds = (total_time_played % SECONDS_TO_MINUTES_FACTOR).to_i
      "#{minutes}m #{remaining_seconds}s"
    else
      "#{total_time_played.to_i}s"
    end
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[user_id score user wins losses total_games win_rate total_time_played highest_book_count]
  end

  def readonly?
    true
  end
end
