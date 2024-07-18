class RoundsController < ApplicationController
  before_action :set_game

  def create
    opponent = round_params[:opponent_id].to_i
    rank = round_params[:rank]
    @game.play_round!(opponent, rank, current_user)
    redirect_to @game
  rescue Game::GameError, GoFish::GoFishError => e
    redirect_to @game, alert: "Error: #{e.message}"
  end

  private

  def set_game
    @game = Game.find(params[:game_id])
  end

  def round_params
    params.permit(:opponent_id, :rank, :game_id, :_method, :authenticity_token, :commit)
  end
end
