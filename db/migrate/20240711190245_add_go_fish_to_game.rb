class AddGoFishToGame < ActiveRecord::Migration[7.1]
  def change
    add_column :games, :go_fish, :jsonb
  end
end
