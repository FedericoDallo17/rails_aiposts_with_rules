module Api
  module V1
    class BaseController < ApplicationController
      before_action :authenticate_user!

      respond_to :json

      private

      def current_user
        @current_user ||= super || User.find_by(id: session[:user_id])
      end
    end
  end
end
