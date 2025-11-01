require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:username) }
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:username) }
    it { should validate_uniqueness_of(:email).case_insensitive }
  end

  describe 'associations' do
    it { should have_many(:posts).dependent(:destroy) }
    it { should have_many(:comments).dependent(:destroy) }
    it { should have_many(:likes).dependent(:destroy) }
    it { should have_many(:reposts).dependent(:destroy) }
    it { should have_many(:notifications).dependent(:destroy) }
    it { should have_many(:following_relationships).class_name('Follow').with_foreign_key(:follower_id).dependent(:destroy) }
    it { should have_many(:follower_relationships).class_name('Follow').with_foreign_key(:followed_id).dependent(:destroy) }
  end

  describe 'factory' do
    it 'has a valid factory' do
      user = build(:user)
      expect(user).to be_valid
    end

    it 'creates a user with all attributes' do
      user = create(:user)
      expect(user.email).to be_present
      expect(user.username).to be_present
      expect(user.encrypted_password).to be_present
    end
  end
end
