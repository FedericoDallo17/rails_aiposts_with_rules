module Api
  module V1
    module Auth
      class PasswordsController < Devise::PasswordsController
        respond_to :json

        def create
          self.resource = resource_class.send_reset_password_instructions(resource_params)

          if successfully_sent?(resource)
            render json: {
              message: "Password reset instructions sent to your email."
            }, status: :ok
          else
            render json: {
              error: "Email not found.",
              errors: resource.errors.full_messages
            }, status: :not_found
          end
        end

        def update
          self.resource = resource_class.reset_password_by_token(resource_params)

          if resource.errors.empty?
            resource.unlock_access! if unlockable?(resource)
            render json: {
              message: "Password changed successfully."
            }, status: :ok
          else
            render json: {
              error: "Failed to reset password.",
              errors: resource.errors.full_messages
            }, status: :unprocessable_entity
          end
        end

        protected

        def resource_params
          params.require(:user).permit(:email, :reset_password_token, :password, :password_confirmation)
        end
      end
    end
  end
end

