class RoundsController < ApplicationController
  before_action :set_game

  def create
    opponent = round_params[:opponent].to_i
    rank = round_params[:rank]
    @game.play_round!(opponent, rank, current_user)
    redirect_to @game, notice: 'Round played'
  rescue Game::GoFishError => e
    render games_path(@game), alert: "Error: #{e.message}"
  end

  private

  def set_game
    @game = Game.find(params[:game_id])
  end

  def round_params
    params.permit(:opponent, :rank, :game_id)
  end
end
