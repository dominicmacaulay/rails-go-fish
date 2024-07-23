class ChangeDefaultForWinner < ActiveRecord::Migration[7.1]
  def change
    change_column_default :game_users, :winner, from: false, to: nil
  end
end
