FactoryBot.define do
  factory :post do
    association :user
    content { Faker::Lorem.paragraph }
    
    trait :with_tags do
      content { "#{Faker::Lorem.sentence} #ruby #rails #testing" }
    end
    
    trait :with_mentions do
      content { "Hello @user1 and @user2!" }
    end
  end
end
