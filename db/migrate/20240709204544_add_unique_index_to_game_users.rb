class AddUniqueIndexToGameUsers < ActiveRecord::Migration[7.1]
  def change
    add_index :game_users, [:game_id, :user_id], unique: true
  end
end
