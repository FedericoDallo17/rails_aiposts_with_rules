FactoryBot.define do
  factory :notification do
    association :user
    association :notifiable, factory: :like
    event_type { 'like' }
    
    trait :comment_notification do
      association :notifiable, factory: :comment
      event_type { 'comment' }
    end
    
    trait :follow_notification do
      association :notifiable, factory: :follow
      event_type { 'follow' }
    end
    
    trait :read do
      read_at { Time.current }
    end
  end
end
