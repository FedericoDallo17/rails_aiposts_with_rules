require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:username) }
    it { should validate_uniqueness_of(:username).case_insensitive }
    it { should validate_length_of(:username).is_at_least(3).is_at_most(30) }
    it { should validate_length_of(:bio).is_at_most(500) }
  end

  describe 'associations' do
    it { should have_many(:posts).dependent(:destroy) }
    it { should have_many(:comments).dependent(:destroy) }
    it { should have_many(:likes).dependent(:destroy) }
    it { should have_many(:liked_posts).through(:likes) }
    it { should have_many(:following_relationships).dependent(:destroy) }
    it { should have_many(:following).through(:following_relationships) }
    it { should have_many(:follower_relationships).dependent(:destroy) }
    it { should have_many(:followers).through(:follower_relationships) }
    it { should have_many(:notifications).dependent(:destroy) }
  end

  describe '#follow' do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }

    it 'creates a follow relationship' do
      expect { user.follow(other_user) }.to change(Follow, :count).by(1)
      expect(user.following?(other_user)).to be true
    end

    it 'does not create duplicate follows' do
      user.follow(other_user)
      expect { user.follow(other_user) }.not_to change(Follow, :count)
    end

    it 'does not allow self-follow' do
      expect { user.follow(user) }.not_to change(Follow, :count)
    end
  end

  describe '#unfollow' do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }

    before { user.follow(other_user) }

    it 'removes the follow relationship' do
      expect { user.unfollow(other_user) }.to change(Follow, :count).by(-1)
      expect(user.following?(other_user)).to be false
    end
  end

  describe '#full_name' do
    it 'returns full name when first and last name present' do
      user = create(:user, first_name: 'John', last_name: 'Doe')
      expect(user.full_name).to eq('John Doe')
    end

    it 'returns username when names are blank' do
      user = create(:user, first_name: '', last_name: '', username: 'johndoe')
      expect(user.full_name).to eq('johndoe')
    end
  end
end
