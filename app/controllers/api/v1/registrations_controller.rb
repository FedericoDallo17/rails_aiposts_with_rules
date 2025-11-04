module Api
  module V1
    class RegistrationsController < Devise::RegistrationsController
      respond_to :json

      def create
        build_resource(sign_up_params)

        resource.save
        yield resource if block_given?
        if resource.persisted?
          if resource.active_for_authentication?
            sign_up(resource_name, resource)
            render json: {
              status: { code: 200, message: "Signed up successfully." },
              data: UserSerializer.new(resource).serializable_hash[:data][:attributes]
            }, status: :ok
          else
            expire_data_after_sign_in!
            render json: {
              status: { code: 200, message: "Signed up successfully." },
              data: UserSerializer.new(resource).serializable_hash[:data][:attributes]
            }, status: :ok
          end
        else
          clean_up_passwords resource
          set_minimum_password_length
          render json: {
            status: { message: "User couldn't be created successfully. #{resource.errors.full_messages.to_sentence}" }
          }, status: :unprocessable_entity
        end
      end

      private

      def respond_with(resource, _opts = {})
        if resource.persisted?
          render json: {
            status: { code: 200, message: "Signed up successfully." },
            data: UserSerializer.new(resource).serializable_hash[:data][:attributes]
          }, status: :ok
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
