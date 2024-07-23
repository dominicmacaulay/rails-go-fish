class UpdateLeaderboardsToVersion5 < ActiveRecord::Migration[7.1]
  def change
    update_view :leaderboards, version: 5, revert_to_version: 4
  end
end
