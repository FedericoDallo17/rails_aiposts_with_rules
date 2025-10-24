require 'rails_helper'

RSpec.describe Follow, type: :model do
  describe 'validations' do
    subject { create(:follow) }
    it { should validate_uniqueness_of(:follower_id).scoped_to(:followed_id) }
  end

  describe 'associations' do
    it { should belong_to(:follower).class_name('User') }
    it { should belong_to(:followed).class_name('User') }
    it { should have_many(:notifications).dependent(:destroy) }
  end

  describe 'custom validations' do
    let(:user) { create(:user) }

    it 'does not allow self-follow' do
      follow = build(:follow, follower: user, followed: user)
      expect(follow).not_to be_valid
      expect(follow.errors[:base]).to include('No puedes seguirte a ti mismo')
    end
  end

  describe 'callbacks' do
    let(:follower) { create(:user) }
    let(:followed) { create(:user) }

    it 'notifies followed user when follow is created' do
      expect {
        create(:follow, follower: follower, followed: followed)
      }.to change(Notification, :count).by(1)
    end
  end

  describe 'uniqueness' do
    let(:follower) { create(:user) }
    let(:followed) { create(:user) }

    it 'does not allow duplicate follows' do
      create(:follow, follower: follower, followed: followed)
      duplicate_follow = build(:follow, follower: follower, followed: followed)
      expect(duplicate_follow).not_to be_valid
    end
  end
end
