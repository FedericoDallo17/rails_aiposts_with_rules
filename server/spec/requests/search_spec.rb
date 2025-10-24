require 'rails_helper'

RSpec.describe 'Search API', type: :request do
  describe 'GET /api/v1/search/users' do
    let!(:user1) { create(:user, username: 'johndoe', first_name: 'John', last_name: 'Doe') }
    let!(:user2) { create(:user, username: 'janedoe', first_name: 'Jane', last_name: 'Doe') }
    let!(:user3) { create(:user, username: 'bob', first_name: 'Bob', last_name: 'Smith') }

    it 'searches users by username' do
      get '/api/v1/search/users?q=john'
      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      usernames = json['users'].map { |u| u['username'] }
      expect(usernames).to include('johndoe')
    end

    it 'searches users by name' do
      get '/api/v1/search/users?q=Doe'
      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      expect(json['users'].length).to be >= 2
    end
  end

  describe 'GET /api/v1/search/posts' do
    let!(:post1) { create(:post, content: 'Learning Ruby on Rails #ruby #rails') }
    let!(:post2) { create(:post, content: 'JavaScript is awesome #javascript') }

    it 'searches posts by content' do
      get '/api/v1/search/posts?q=Ruby'
      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      contents = json['posts'].map { |p| p['content'] }
      expect(contents.any? { |c| c.include?('Ruby') }).to be true
    end

    it 'sorts posts by newest' do
      get '/api/v1/search/posts?q=awesome&sort=newest'
      expect(response).to have_http_status(:success)
    end
  end
end

