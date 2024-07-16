class GameUsersController < ApplicationController
  before_action :set_game, only: %i[create destroy]
  before_action :set_game_user, only: %i[destroy]

  def create
    if @game.queue_full? || @game.users.include?(current_user)
      redirect_to games_path, notice: 'You cannot join this game.'
    else
      @game_user = @game.game_users.build(user: current_user)

      if @game_user.save
        @game.start!
        redirect_to @game, notice: 'You have joined a game'
      else
        redirect_to games_path, status: :unprocessable_entity
      end
    end
  end

  def destroy
    @game_user.destroy

    # redirect_to @game, notice: 'Game was successfully destroyed.'
    # respond_to do |format|
    #   format.html { redirect_to games_path, notice: 'Game was successfully destroyed.' }
    #   format.turbo_stream { flash.now[:notice] = 'Game was successfully destroyed.' }
    # end
  end

  private

  def set_game
    @game = Game.find(params[:game_id])
  end

  def set_game_user
    @game_user = GameUser.find(params[:id])
  end
end
