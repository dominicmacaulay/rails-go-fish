SELECT
	users.id AS user_id,
	COALESCE(users_with_books.total_book_value, 0) AS score,
	CONCAT(users.first_name, ' ', users.last_name) AS user,
	COALESCE(winners.wins, 0) AS wins,
	COALESCE(losers.losses, 0) AS losses,
	COALESCE(winners.wins, 0) + COALESCE(losers.losses, 0) AS total_games,
	CASE
		WHEN COALESCE(winners.wins, 0) = 0 THEN 0
		WHEN COALESCE(losers.losses, 0) = 0 THEN 1
		ELSE ROUND(winners.wins / CAST(COALESCE(winners.wins, 0) + COALESCE(losers.losses, 0) AS DECIMAL), 2)
	END AS win_rate,
	COALESCE(games.total_time, 0) AS total_time_played,
	COALESCE(users_with_books.highest_book_count, 0) AS highest_book_count
FROM users
-- gather the winners
LEFT JOIN (
	SELECT
		users.id AS user_id,
		count(winners) AS wins
	FROM users
	INNER JOIN game_users AS winners ON winners.user_id = users.id AND winners.winner = true
	GROUP BY users.id
) AS winners ON users.id = winners.user_id
-- gather the losers
LEFT JOIN (
	SELECT
		users.id AS user_id,
		count(losers) AS losses
	FROM users
	INNER JOIN game_users AS losers ON losers.user_id = users.id AND losers.winner = false
	GROUP BY users.id
) AS losers ON users.id = losers.user_id
-- gather the total time in seconds
LEFT JOIN (
	SELECT
		users.id AS user_id,
		SUM(
			CASE
				WHEN COALESCE(EXTRACT(EPOCH FROM (games.finished_at)), 0) = 0 THEN COALESCE(EXTRACT(EPOCH FROM (games.updated_at - games.started_at)), 0)
				ELSE EXTRACT(EPOCH FROM (games.finished_at - games.started_at))
			END
		) AS total_time
	FROM users
	INNER JOIN game_users ON game_users.user_id = users.id
	INNER JOIN games ON game_users.game_id = games.id AND games.started = true
	GROUP BY users.id
) AS games ON users.id = games.user_id
-- gather the highest book count
LEFT JOIN (
	SELECT
		users.id AS user_id,
		MAX(game_users.books) AS highest_book_count,
		SUM(game_users.book_value) AS total_book_value
	FROM users
	INNER JOIN game_users ON game_users.user_id = users.id AND game_users.books > 0
	GROUP BY users.id
) as users_with_books ON users.id = users_with_books.user_id