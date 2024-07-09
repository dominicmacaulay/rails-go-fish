require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'name' do
    let(:user) { create(:user, email: 'dominic@gmail.com') }
    it 'returns the capitalized name based off of the email' do
      expect(user.name).to eql 'Dominic'
    end
  end
end
