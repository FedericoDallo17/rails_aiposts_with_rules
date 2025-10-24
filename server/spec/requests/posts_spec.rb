require 'rails_helper'

RSpec.describe 'Posts API', type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:headers) { {'Authorization' => "Bearer #{generate_jwt_token(user)}"} }

  describe 'GET /api/v1/posts' do
    before do
      create_list(:post, 5, user: user)
      create_list(:post, 3, user: other_user)
    end

    it 'returns all posts' do
      get '/api/v1/posts'
      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      expect(json['posts'].length).to eq(8)
    end

    it 'filters posts by user_id' do
      get "/api/v1/posts?user_id=#{user.id}"
      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      expect(json['posts'].length).to eq(5)
      expect(json['posts'].all? { |p| p['user']['id'] == user.id }).to be true
    end
  end

  describe 'POST /api/v1/posts' do
    context 'when authenticated' do
      it 'creates a new post' do
        post_params = {post: {content: 'Test post content #ruby'}}
        
        expect {
          post '/api/v1/posts', params: post_params, headers: headers, as: :json
        }.to change(Post, :count).by(1)
        
        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json['content']).to eq('Test post content #ruby')
        expect(json['tags']).to include('ruby')
      end
    end

    context 'when not authenticated' do
      it 'returns unauthorized' do
        post_params = {post: {content: 'Test post'}}
        post '/api/v1/posts', params: post_params, as: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'POST /api/v1/posts/:id/like' do
    let(:post_to_like) { create(:post, user: other_user) }

    it 'likes a post' do
      expect {
        post "/api/v1/posts/#{post_to_like.id}/like", headers: headers
      }.to change(Like, :count).by(1)
      
      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      expect(json['likes_count']).to eq(1)
    end
  end

  def generate_jwt_token(user)
    # Simple JWT token generation for tests
    payload = {sub: user.id, exp: 24.hours.from_now.to_i}
    JWT.encode(payload, Rails.application.credentials.secret_key_base, 'HS256')
  end
end

