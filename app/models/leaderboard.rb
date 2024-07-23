class Leaderboard < ApplicationRecord
  self.primary_key = :id

  def readonly?
    true
  end
end
