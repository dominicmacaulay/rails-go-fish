class GamesController < ApplicationController
  before_action :set_game, only: %i[show edit update destroy]

  def index
    @games = Game.order(created_at: :desc)
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
      redirect_to games_path, notice: "#{@game.name} was successfully created"
    else
      render :new, status: :unprocessable_entity, layout: 'modal'
    end
  end

  def update
    if @game.update(game_params)
      redirect_to games_path, notice: "#{@game.name} was successfully created"
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

  def leaderboard
    @users = User.all
  end

  def game_status
    @games = Game.all.select(&:started?)
  end

  private

  def set_game
    @game = Game.find(params[:id])
  end

  def game_params
    params.require(:game).permit(:name, :number_of_players)
  end
end
