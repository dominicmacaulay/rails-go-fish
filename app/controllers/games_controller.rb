class GamesController < ApplicationController
  before_action :set_game, only: %i[show edit update destroy]

  def index
    @games = Game.order(created_at: :desc)
  end

  def show
    @users = @game.users
  end

  def new
    @game = Game.build
  end

  def edit
  end

  def create
    @game = Game.build(game_params)

    if @game.save
      @game.users << current_user
      # redirect_to games_path, notice: 'Game was successfully created.'
      respond_to do |format|
        format.html { redirect_to games_path, notice: 'Game was successfully created.' }
        format.turbo_stream { flash.now[:notice] = 'Game was successfully created.' }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @game.update(game_params)
      # redirect_to games_path, notice: 'Game was successfully updated.'
      respond_to do |format|
        format.html { redirect_to games_path, notice: 'Game was successfully updated.' }
        format.turbo_stream { flash.now[:notice] = 'Game was successfully updated.' }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @game.destroy
    # @game.users.each(&:destroy)

    # redirect_to games_path, notice: 'Game was successfully destroyed.'
    respond_to do |format|
      format.html { redirect_to games_path, notice: 'Game was successfully destroyed.' }
      format.turbo_stream { flash.now[:notice] = 'Game was successfully destroyed.' }
    end
  end

  private

  def set_game
    @game = Game.find(params[:id])
  end

  def game_params
    params.require(:game).permit(:name, :number_of_players)
  end
end
