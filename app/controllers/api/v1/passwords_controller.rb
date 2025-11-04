module Api
  module V1
    class PasswordsController < Devise::PasswordsController
      respond_to :json
      skip_before_action :verify_authenticity_token

      def create
        self.resource = resource_class.send_reset_password_instructions(resource_params)
        if successfully_sent?(resource)
          render json: {
            status: { code: 200, message: "Password reset instructions sent." }
          }
        else
          render json: {
            status: { message: "Email not found." }
          }, status: :not_found
        end
      end

      def update
        self.resource = resource_class.reset_password_by_token(resource_params)

        if resource.errors.empty?
          resource.unlock_access! if unlockable?(resource)
          render json: {
            status: { code: 200, message: "Password updated successfully." }
          }
        else
          render json: {
            status: { message: resource.errors.full_messages.to_sentence }
          }, status: :unprocessable_entity
        end
      end
    end
  end
end
