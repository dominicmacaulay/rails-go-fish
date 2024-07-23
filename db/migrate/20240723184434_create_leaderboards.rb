class CreateLeaderboards < ActiveRecord::Migration[7.1]
  def change
    create_view :leaderboards
  end
end
