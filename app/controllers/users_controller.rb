class UsersController < ApplicationController
  def user_details
    if request.headers.present? and request.headers['Authorization']
    header = request.headers['Authorization']
    header = header.split(' ').last if header
    if header != 'null'
      begin
        decoded = JsonWebToken.decode(header)
        if decoded[:user_id]
          current_user = User.find_by(id: decoded[:user_id])
          if current_user
            user_data = current_user.as_json(except: [:password_digest])
            render json: { user: user_data }, status: :ok
          else
            render json: { errors: 'no user record found' }, status: :unauthorized
          end
        else
          render json: { errors: 'Token Null' }, status: :unauthorized
        end
      rescue ActiveRecord::RecordNotFound => e
        render json: { errors: e.message }, status: :unauthorized
      rescue JWT::DecodeError => e
        render json: { errors: e.message }, status: :unauthorized
      end
    else
      render json: { errors: 'Token Null' }, status: :unauthorized
    end
    else
      render json: { errors: "Token Missing" }, status: :unauthorized
    end
  end
end