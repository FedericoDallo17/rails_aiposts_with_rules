require 'rails_helper'

RSpec.describe Comment, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:content) }
    it { should validate_length_of(:content).is_at_least(1).is_at_most(2000) }
  end

  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:post).counter_cache(true) }
    it { should have_many(:notifications).dependent(:destroy) }
  end

  describe 'callbacks' do
    let(:post_author) { create(:user) }
    let(:commenter) { create(:user) }
    let(:post_obj) { create(:post, user: post_author) }

    it 'notifies post author when comment is created' do
      expect {
        create(:comment, post: post_obj, user: commenter)
      }.to change(Notification, :count).by_at_least(1)
    end

    it 'does not notify post author if they are the commenter' do
      initial_count = Notification.count
      create(:comment, post: post_obj, user: post_author)
      # May still create notifications for mentions, but not for comment event
      # This is a basic check
      expect(Notification.where(event_type: 'comment').count).to eq(initial_count)
    end
  end
end
