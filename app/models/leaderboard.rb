class Leaderboard < ApplicationRecord
  self.primary_key = :user_id

  def readonly?
    true
  end
end
