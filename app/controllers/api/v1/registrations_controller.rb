module Api
  module V1
    class RegistrationsController < Devise::RegistrationsController
      respond_to :json
      skip_before_action :verify_authenticity_token

      private

      def respond_with(resource, _opts = {})
        if resource.persisted?
          render json: {
            status: { code: 200, message: "Signed up successfully." },
            data: UserSerializer.new(resource).serializable_hash[:data][:attributes]
          }
        else
          render json: {
            status: { message: "User couldn't be created successfully. #{resource.errors.full_messages.to_sentence}" }
          }, status: :unprocessable_entity
        end
      end

      def sign_up_params
        params.require(:user).permit(:email, :password, :password_confirmation, :username, :first_name, :last_name, :bio, :website, :location)
      end

      def account_update_params
        params.require(:user).permit(:email, :password, :password_confirmation, :current_password, :username, :first_name, :last_name, :bio, :website, :location, :profile_picture, :cover_picture)
      end
    end
  end
end
