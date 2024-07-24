class HistoryController < ApplicationController
  def index
    @q = Game.finished.ransack(params[:q])
    @games = @q.result.order(created_at: :desc).page params[:page]
  end
end
