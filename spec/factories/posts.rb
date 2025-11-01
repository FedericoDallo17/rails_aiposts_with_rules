FactoryBot.define do
  factory :post do
    content { "This is a sample post" }
    tags { [ "rails", "ruby" ] }
    association :user
  end
end
