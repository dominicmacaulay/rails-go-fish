class RoundsController < ApplicationController
  before_action :set_game

  def create
    opponent = round_params[:opponent].to_i
    rank = round_params[:rank]
    if @game.play_round!(opponent, rank, current_user)
      redirect_to @game, notice: 'Round played'
    else
      redirect_to @game, alert: 'Error, Try taking your turn again'
    end
  end

  private

  def set_game
    @game = Game.find(params[:game_id])
  end

  def round_params
    params.permit(:opponent, :rank, :game_id)
  end
end
