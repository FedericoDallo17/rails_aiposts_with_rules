require 'rails_helper'

RSpec.describe 'Users API', type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:headers) { {'Authorization' => "Bearer #{generate_jwt_token(user)}"} }

  describe 'GET /api/v1/users' do
    before do
      create_list(:user, 5)
    end

    it 'returns all users' do
      get '/api/v1/users'
      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      expect(json['users'].length).to be >= 5
    end
  end

  describe 'GET /api/v1/users/:id' do
    it 'returns a specific user' do
      get "/api/v1/users/#{other_user.id}"
      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      expect(json['username']).to eq(other_user.username)
    end
  end

  describe 'POST /api/v1/users/:id/follow' do
    it 'allows authenticated user to follow another user' do
      expect {
        post "/api/v1/users/#{other_user.id}/follow", headers: headers
      }.to change(Follow, :count).by(1)
      
      expect(response).to have_http_status(:success)
      expect(user.following?(other_user)).to be true
    end

    it 'does not allow self-follow' do
      post "/api/v1/users/#{user.id}/follow", headers: headers
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'DELETE /api/v1/users/:id/unfollow' do
    before do
      user.follow(other_user)
    end

    it 'allows authenticated user to unfollow' do
      expect {
        delete "/api/v1/users/#{other_user.id}/unfollow", headers: headers
      }.to change(Follow, :count).by(-1)
      
      expect(response).to have_http_status(:success)
      expect(user.following?(other_user)).to be false
    end
  end

  def generate_jwt_token(user)
    payload = {sub: user.id, exp: 24.hours.from_now.to_i}
    JWT.encode(payload, Rails.application.credentials.secret_key_base, 'HS256')
  end
end

