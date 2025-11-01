class UserSerializer
  def initialize(user)
    @user = user
  end

  def serializable_hash
    {
      data: {
        id: @user.id,
        type: :user,
        attributes: {
          id: @user.id,
          email: @user.email,
          username: @user.username,
          first_name: @user.first_name,
          last_name: @user.last_name,
          bio: @user.bio,
          website: @user.website,
          location: @user.location,
          profile_picture: @user.profile_picture,
          cover_picture: @user.cover_picture,
          created_at: @user.created_at,
          updated_at: @user.updated_at
        }
      }
    }
  end
end
