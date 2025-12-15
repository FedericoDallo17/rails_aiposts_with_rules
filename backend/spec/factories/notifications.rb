FactoryBot.define do
  factory :notification do
    message { "Test notification" }
    notification_type { "like" }
    read_at { nil }
    association :user
    association :actor, factory: :user
    association :notifiable, factory: :post
  end
end
