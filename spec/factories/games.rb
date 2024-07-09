FactoryBot.define do
  factory :game do
    sequence(:name) { |n| "Game #{n}" }
    number_of_players { 2 }
  end
end
