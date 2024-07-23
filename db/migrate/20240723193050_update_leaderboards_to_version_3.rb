class UpdateLeaderboardsToVersion3 < ActiveRecord::Migration[7.1]
  def change
    update_view :leaderboards, version: 3, revert_to_version: 3
  end
end
