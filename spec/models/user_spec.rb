require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'name' do
    let(:user) { create(:user, first_name: 'Dominic', last_name: 'MacAulay', email: 'dominic@gmail.com') }
    it 'returns the full name of the user' do
      expect(user.name).to eql 'Dominic MacAulay'
    end
  end
end
