# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2024_07_23_200816) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "game_users", force: :cascade do |t|
    t.bigint "game_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "winner"
    t.integer "books"
    t.index ["game_id", "user_id"], name: "index_game_users_on_game_id_and_user_id", unique: true
    t.index ["game_id"], name: "index_game_users_on_game_id"
    t.index ["user_id"], name: "index_game_users_on_user_id"
  end

  create_table "games", force: :cascade do |t|
    t.string "name", null: false
    t.integer "number_of_players", default: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "go_fish"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.boolean "started", default: false
    t.boolean "over", default: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "game_users", "games"
  add_foreign_key "game_users", "users"

  create_view "leaderboards", sql_definition: <<-SQL
      SELECT users.id AS user_id,
      COALESCE(winners.total_book_count, (0)::bigint) AS score,
      concat(users.first_name, ' ', users.last_name) AS "user",
      COALESCE(winners.wins, (0)::bigint) AS wins,
      COALESCE(losers.losses, (0)::bigint) AS losses,
      (COALESCE(winners.wins, (0)::bigint) + COALESCE(losers.losses, (0)::bigint)) AS total_games,
          CASE
              WHEN (COALESCE(winners.wins, (0)::bigint) = 0) THEN (0)::numeric
              WHEN (COALESCE(losers.losses, (0)::bigint) = 0) THEN (1)::numeric
              ELSE round(((winners.wins)::numeric / ((COALESCE(winners.wins, (0)::bigint) + COALESCE(losers.losses, (0)::bigint)))::numeric), 2)
          END AS win_rate,
      COALESCE(games.total_time, (0)::numeric) AS total_time_played,
      COALESCE(users_with_books.highest_book_count, 0) AS highest_book_count
     FROM ((((users
       LEFT JOIN ( SELECT users_1.id AS user_id,
              count(winners_1.*) AS wins,
              sum(winners_1.books) AS total_book_count
             FROM (users users_1
               JOIN game_users winners_1 ON (((winners_1.user_id = users_1.id) AND (winners_1.winner = true))))
            GROUP BY users_1.id) winners ON ((users.id = winners.user_id)))
       LEFT JOIN ( SELECT users_1.id AS user_id,
              count(losers_1.*) AS losses
             FROM (users users_1
               JOIN game_users losers_1 ON (((losers_1.user_id = users_1.id) AND (losers_1.winner = false))))
            GROUP BY users_1.id) losers ON ((users.id = losers.user_id)))
       LEFT JOIN ( SELECT users_1.id AS user_id,
              sum(GREATEST(COALESCE(EXTRACT(epoch FROM (games_1.finished_at - games_1.started_at)), (0)::numeric), COALESCE(EXTRACT(epoch FROM (games_1.updated_at - games_1.started_at)), (0)::numeric))) AS total_time
             FROM ((users users_1
               JOIN game_users ON ((game_users.user_id = users_1.id)))
               JOIN games games_1 ON (((game_users.game_id = games_1.id) AND (games_1.started = true))))
            GROUP BY users_1.id) games ON ((users.id = games.user_id)))
       LEFT JOIN ( SELECT users_1.id AS user_id,
              max(game_users.books) AS highest_book_count
             FROM (users users_1
               JOIN game_users ON (((game_users.user_id = users_1.id) AND (game_users.books > 0))))
            GROUP BY users_1.id) users_with_books ON ((users.id = users_with_books.user_id)));
  SQL
end
