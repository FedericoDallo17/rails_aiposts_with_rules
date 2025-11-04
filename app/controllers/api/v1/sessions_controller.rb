module Api
  module V1
    class SessionsController < Devise::SessionsController
      respond_to :json

      before_action :configure_sign_in_params, only: [ :create ]

      def create
        self.resource = warden.authenticate(auth_options)

        if resource
          sign_in(resource_name, resource)
          render json: {
            status: { code: 200, message: "Logged in successfully." },
            data: UserSerializer.new(resource).serializable_hash[:data][:attributes]
          }, status: :ok
        else
          render json: {
            error: "Invalid email or password"
          }, status: :unauthorized
        end
      end

      def destroy
        if current_user
          sign_out(current_user)
          render json: {
            status: 200,
            message: "Logged out successfully."
          }, status: :ok
        else
          render json: {
            status: 401,
            message: "Couldn't find an active session."
          }, status: :unauthorized
        end
      end

      private

      def configure_sign_in_params
        devise_parameter_sanitizer.permit(:sign_in, keys: [ :email, :password ])
      end

      def respond_with(resource, _opts = {})
        render json: {
          status: { code: 200, message: "Logged in successfully." },
          data: UserSerializer.new(resource).serializable_hash[:data][:attributes]
        }, status: :ok
      end

      def respond_to_on_destroy
        if current_user
          render json: {
            status: 200,
            message: "Logged out successfully."
          }, status: :ok
        else
          render json: {
            status: 401,
            message: "Couldn't find an active session."
          }, status: :unauthorized
        end
      end
    end
  end
end
