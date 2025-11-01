FactoryBot.define do
  factory :repost do
    association :user
    association :post
  end
end
