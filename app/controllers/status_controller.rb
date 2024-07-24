class StatusController < ApplicationController
  def index
    @q = Game.in_progress.ransack(params[:q])
    @games = @q.result.order(created_at: :desc).page params[:page]
  end
end
