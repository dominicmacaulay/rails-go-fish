require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'name' do
    let(:user) { create(:user, first_name: 'Dominic', email: 'dominic@gmail.com') }
    it 'returns the capitalized name based off of the email' do
      expect(user.first_name).to eql 'Dominic'
    end
  end
end
