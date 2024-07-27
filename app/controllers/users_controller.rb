class UsersController < ApplicationController
  def user_details
    header = request.headers['Authorization']
    header = header.split(' ').last if header
    if header
      begin
        decoded = JsonWebToken.decode(header)
        current_user = User.find_by(id: decoded[:user_id])
        if current_user
          render json: { user: current_user }, status: :ok
        else
          render json: { errors: 'no user record found' }, status: :unauthorized
        end
      rescue ActiveRecord::RecordNotFound => e
      render json: { errors: e.message }, status: :unauthorized
      rescue JWT::DecodeError => e
        render json: { errors: e.message }, status: :unauthorized
      end
    else
      render json: { errors: "Token Missing" }, status: :unauthorized
    end
  end
end