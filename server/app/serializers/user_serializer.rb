class UserSerializer
  def initialize(user)
    @user = user
  end

  def as_json
    {
      id: @user.id,
      email: @user.email,
      username: @user.username,
      first_name: @user.first_name,
      last_name: @user.last_name,
      full_name: @user.full_name,
      bio: @user.bio,
      website: @user.website,
      location: @user.location,
      profile_picture_url: profile_picture_url,
      cover_picture_url: cover_picture_url,
      followers_count: @user.followers.count,
      following_count: @user.following.count,
      posts_count: @user.posts.count,
      created_at: @user.created_at,
      updated_at: @user.updated_at
    }
  end

  private

  def profile_picture_url
    return nil unless @user.profile_picture.attached?

    Rails.application.routes.url_helpers.rails_blob_url(@user.profile_picture, only_path: true)
  end

  def cover_picture_url
    return nil unless @user.cover_picture.attached?

    Rails.application.routes.url_helpers.rails_blob_url(@user.cover_picture, only_path: true)
  end
end

