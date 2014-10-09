module Api::V1
  class UsersController < Api::V1::ApiController
    load_and_authorize_resource :user, parent: false

    def index
      @users = @users.find( params[:ids].split(",") ) if params[:ids].present?
      render json: @users, each_serializer: serializer
    end

    def show
      render json: @user, serializer: serializer
    end

    private

    def serializer
      Api::V1::UserSerializer
    end

  end
end
