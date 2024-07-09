require 'rails_helper'

RSpec.describe GameUser, type: :model do
  let(:game) { create(:game) }
  let(:user) { create(:user) }

  def create_game_user
    create(:game_user, game:, user:)
  end

  it 'enforces database uniqueness constraint' do
    create_game_user
    expect { create_game_user }.to raise_error(ActiveRecord::RecordNotUnique)
  end
end
