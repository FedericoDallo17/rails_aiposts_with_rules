require 'rails_helper'

RSpec.describe Post, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:content) }
    it { should validate_length_of(:content).is_at_least(1).is_at_most(5000) }
  end

  describe 'associations' do
    it { should belong_to(:user) }
    it { should have_many(:comments).dependent(:destroy) }
    it { should have_many(:likes).dependent(:destroy) }
    it { should have_many(:likers).through(:likes) }
  end

  describe '#extract_tags' do
    it 'extracts hashtags from content' do
      post = create(:post, content: 'Hello #world #ruby #rails')
      expect(post.tags).to contain_exactly('world', 'ruby', 'rails')
    end

    it 'converts tags to lowercase' do
      post = create(:post, content: 'Hello #Ruby #Rails')
      expect(post.tags).to contain_exactly('ruby', 'rails')
    end

    it 'removes duplicate tags' do
      post = create(:post, content: '#ruby #ruby #rails')
      expect(post.tags).to contain_exactly('ruby', 'rails')
    end

    it 'limits to 10 tags' do
      content = (1..15).map { |i| "#tag#{i}" }.join(' ')
      post = create(:post, content: content)
      expect(post.tags.length).to eq(10)
    end
  end

  describe '#mentioned_users' do
    let!(:user1) { create(:user, username: 'alice') }
    let!(:user2) { create(:user, username: 'bob') }

    it 'returns mentioned users' do
      post = create(:post, content: 'Hello @alice and @bob')
      mentioned = post.mentioned_users
      expect(mentioned).to contain_exactly(user1, user2)
    end

    it 'returns empty array when no mentions' do
      post = create(:post, content: 'Hello world')
      expect(post.mentioned_users).to be_empty
    end
  end

  describe '#liked_by?' do
    let(:post) { create(:post) }
    let(:user) { create(:user) }

    it 'returns true when user liked the post' do
      create(:like, user: user, post: post)
      expect(post.liked_by?(user)).to be true
    end

    it 'returns false when user has not liked the post' do
      expect(post.liked_by?(user)).to be false
    end
  end
end
