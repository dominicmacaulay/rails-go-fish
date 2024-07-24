class LeaderboardController < ApplicationController
  def index
    @q = Leaderboard.ransack(params[:q])
    page = (params[:page].presence || 1).to_i
    @leaderboards = @q.result.order(score: :desc).page(page)

    @ranked_leaderboards = @leaderboards.each_with_index.map do |leaderboard, index|
      leaderboard.rank = ((page - 1) * @leaderboards.limit_value) + index + 1
      leaderboard
    end
  end
end
