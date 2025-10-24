module Api
  module V1
    module Auth
      class RegistrationsController < Devise::RegistrationsController
        respond_to :json

        private

        def respond_with(resource, _opts = {})
          if resource.persisted?
            render json: {
              message: "Signed up successfully.",
              user: UserSerializer.new(resource).as_json
            }, status: :created
          else
            render json: {
              error: "User couldn't be created successfully.",
              errors: resource.errors.full_messages
            }, status: :unprocessable_entity
          end
        end

        def respond_to_on_destroy
          if current_user
            render json: {
              message: "Account deleted successfully."
            }, status: :ok
          else
            render json: {
              error: "Couldn't find an active session."
            }, status: :unauthorized
          end
        end

        def sign_up_params
          params.require(:user).permit(:email, :password, :password_confirmation, :username, :first_name, :last_name)
        end

        def account_update_params
          params.require(:user).permit(:email, :password, :password_confirmation, :current_password, :username, :first_name, :last_name, :bio, :website, :location)
        end
      end
    end
  end
end

