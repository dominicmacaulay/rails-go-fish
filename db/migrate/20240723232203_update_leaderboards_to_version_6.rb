class UpdateLeaderboardsToVersion6 < ActiveRecord::Migration[7.1]
  def change
    update_view :leaderboards, version: 6, revert_to_version: 5
  end
end
