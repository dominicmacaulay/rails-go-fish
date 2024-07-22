class AddStartedAndOverToGames < ActiveRecord::Migration[7.1]
  def change
    add_column :games, :started, :boolean, default: false
    add_column :games, :over, :boolean, default: false
  end
end
