class AddBooksColumnToGameUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :game_users, :books, :integer, default: nil
  end
end
