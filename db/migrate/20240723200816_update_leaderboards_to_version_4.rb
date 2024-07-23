class UpdateLeaderboardsToVersion4 < ActiveRecord::Migration[7.1]
  def change
    update_view :leaderboards, version: 4, revert_to_version: 3
  end
end
