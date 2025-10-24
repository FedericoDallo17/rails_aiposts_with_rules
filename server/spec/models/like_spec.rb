require 'rails_helper'

RSpec.describe Like, type: :model do
  describe 'validations' do
    subject { create(:like) }
    it { should validate_uniqueness_of(:user_id).scoped_to(:post_id) }
  end

  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:post).counter_cache(true) }
    it { should have_many(:notifications).dependent(:destroy) }
  end

  describe 'callbacks' do
    let(:post_author) { create(:user) }
    let(:liker) { create(:user) }
    let(:post_obj) { create(:post, user: post_author) }

    it 'notifies post author when like is created' do
      expect {
        create(:like, post: post_obj, user: liker)
      }.to change(Notification, :count).by(1)
    end

    it 'does not notify post author if they like their own post' do
      expect {
        create(:like, post: post_obj, user: post_author)
      }.not_to change(Notification, :count)
    end
  end

  describe 'uniqueness' do
    let(:user) { create(:user) }
    let(:post_obj) { create(:post) }

    it 'does not allow duplicate likes' do
      create(:like, user: user, post: post_obj)
      duplicate_like = build(:like, user: user, post: post_obj)
      expect(duplicate_like).not_to be_valid
    end
  end
end
