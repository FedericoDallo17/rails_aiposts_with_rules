module Api
  module V1
    class SessionsController < Devise::SessionsController
      respond_to :json

      def create
        user = User.find_by(email: params[:user][:email])

        if user&.valid_password?(params[:user][:password])
          sign_in(user)
          render json: {
            status: { code: 200, message: "Logged in successfully." },
            data: UserSerializer.new(user).serializable_hash[:data][:attributes]
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
