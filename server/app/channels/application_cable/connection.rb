module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private

    def find_verified_user
      # Extract JWT token from query parameters
      token = request.params[:token]

      if token
        begin
          # Decode JWT token
          secret = ENV.fetch("DEVISE_JWT_SECRET_KEY", Rails.application.credentials.secret_key_base)
          decoded_token = JWT.decode(token, secret, true, {algorithm: "HS256"})
          user_id = decoded_token.first["sub"]

          if verified_user = User.find_by(id: user_id)
            verified_user
          else
            reject_unauthorized_connection
          end
        rescue JWT::DecodeError, JWT::ExpiredSignature
          reject_unauthorized_connection
        end
      else
        reject_unauthorized_connection
      end
    end
  end
end
