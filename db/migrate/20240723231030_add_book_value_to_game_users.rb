class AddBookValueToGameUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :game_users, :book_value, :integer, default: nil
  end
end
