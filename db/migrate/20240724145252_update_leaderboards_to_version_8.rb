class UpdateLeaderboardsToVersion8 < ActiveRecord::Migration[7.1]
  def change
    update_view :leaderboards, version: 8, revert_to_version: 7
  end
end
