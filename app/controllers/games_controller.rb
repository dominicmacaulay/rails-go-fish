class GamesController < ApplicationController
  before_action :set_game, only: %i[show edit update destroy spectate]

  def index
    @my_games = current_user.games.unfinished
    @games = Game.joinable.page params[:page]
  end

  def show
    @users = @game.users
    render layout: 'application_without_panel'
  end

  def new
    @game = Game.build
    render layout: 'modal'
  end

  def edit
    render layout: 'modal'
  end

  def create
    @game = Game.build(game_params)

    if @game.save
      @game.users << current_user
      respond_to do |format|
        format.html { redirect_to games_path, notice: "#{@game.name} was successfully created" }
        format.turbo_stream { flash.now[:notice] = "#{@game.name} was successfully created" }
      end
    else
      render :new, status: :unprocessable_entity, layout: 'modal'
    end
  end

  def update
    if @game.update(game_params)
      respond_to do |format|
        format.html { redirect_to games_path, notice: "#{@game.name} was successfully updated" }
        format.turbo_stream { flash.now[:notice] = "#{@game.name} was successfully updated" }
      end
    else
      render :edit, status: :unprocessable_entity, layout: 'modal'
    end
  end

  def destroy
    if @game.destroy
      respond_to do |format|
        format.html { redirect_to games_path, notice: "#{@game.name} was successfully destroyed" }
        format.turbo_stream { flash.now[:notice] = "#{@game.name} was successfully destroyed" }
      end
    else
      redirect_to games_path, notice: "#{@game.name} could not be destroyed"
    end
  end

  def spectate
    @source = params[:source]
  end

  private

  def set_game
    @game = Game.find(params[:id])
  end

  def game_params
    params.require(:game).permit(:name, :number_of_players)
  end
end
