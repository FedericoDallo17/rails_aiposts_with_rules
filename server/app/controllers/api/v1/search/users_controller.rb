module Api
  module V1
    module Search
      class UsersController < BaseController
        skip_before_action :authenticate_user!, only: [:index]

        # GET /api/v1/search/users?q=query
        def index
          if params[:q].blank?
            render json: {users: [], pagination: {}}
            return
          end

          query = "%#{params[:q]}%"
          @users = User.where(
            "username ILIKE ? OR first_name ILIKE ? OR last_name ILIKE ? OR email ILIKE ? OR location ILIKE ?",
            query, query, query, query, query
          )

          @pagy, @users = pagy(@users, items: params[:per_page] || 20)

          render json: {
            users: @users.map { |user| UserSerializer.new(user).as_json },
            pagination: pagy_metadata(@pagy)
          }
        end

        private

        def pagy_metadata(pagy)
          {
            current_page: pagy.page,
            per_page: pagy.items,
            total_pages: pagy.pages,
            total_count: pagy.count
          }
        end
      end
    end
  end
end

