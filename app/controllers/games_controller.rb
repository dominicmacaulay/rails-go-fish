class GamesController < ApplicationController
  before_action :set_game, only: %i[show edit update destroy]

  def index
    @my_games = current_user.games.joinable
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
    @q = Leaderboard.ransack(params[:q])
    page = (params[:page].presence || 1).to_i
    @leaderboards = @q.result.order(score: :desc).page(page)

    @ranked_leaderboards = @leaderboards.each_with_index.map do |leaderboard, index|
      leaderboard.rank = ((page - 1) * @leaderboards.limit_value) + index + 1
      leaderboard
    end
    # @users = User.includes(:game_users, :games).sort do |a, b|
    #   [b.win_rate, b.wins] <=> [a.win_rate, a.wins]
    # end
  end

  def game_status
    @games = Game.in_progress.page params[:page]
  end

  def game_history
    @games = Game.finished.page params[:page]
  end

  private

  def set_game
    @game = Game.find(params[:id])
  end

  def game_params
    params.require(:game).permit(:name, :number_of_players, :page)
  end
end
