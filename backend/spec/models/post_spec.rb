require 'rails_helper'

RSpec.describe Post, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:content) }
  end

  describe 'associations' do
    it { should belong_to(:user) }
    it { should have_many(:comments).dependent(:destroy) }
    it { should have_many(:likes).dependent(:destroy) }
    it { should have_many(:reposts).dependent(:destroy) }
  end

  describe 'factory' do
    it 'has a valid factory' do
      post = build(:post)
      expect(post).to be_valid
    end

    it 'creates a post with content' do
      post = create(:post)
      expect(post.content).to be_present
      expect(post.user).to be_present
    end
  end

  describe 'scopes' do
    let!(:old_post) { create(:post, created_at: 2.days.ago) }
    let!(:new_post) { create(:post, created_at: 1.day.ago) }

    it 'orders posts by newest first' do
      expect(Post.newest_first.first).to eq(new_post)
    end

    it 'orders posts by oldest first' do
      expect(Post.oldest_first.first).to eq(old_post)
    end
  end
end
