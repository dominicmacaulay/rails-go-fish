class GamesController < ApplicationController
  before_action :set_game, only: %i[show edit update destroy]

  def index
    @games = Game.all
  end

  def show
  end

  def new
    @game = Game.build
  end

  def edit
  end

  def create
    @game = Game.build(game_params)

    if @game.save
      redirect_to games_path, notice: 'Game was successfully created.'
      # respond_to do |format|
      #   format.html { redirect_to games_path, notice: 'Game was successfully created.' }
      #   format.turbo_stream { flash.now[:notice] = 'Game was successfully created.' }
      # end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @game.update(game_params)
      redirect_to games_path, notice: 'Game was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @game.destroy

    redirect_to games_path, notice: 'Game was successfully destroyed.'
    # respond_to do |format|
    #   format.html { redirect_to games_path, notice: 'Game was successfully destroyed.' }
    #   format.turbo_stream { flash.now[:notice] = 'Game was successfully destroyed.' }
    # end
  end

  private

  def set_game
    @game = Game.find(params[:id])
  end

  def game_params
    params.require(:game).permit(:name)
  end
end
