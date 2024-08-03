class UsersController < ApplicationController

  before_action :user_params, only: [:update_full_name]
  before_action :set_user, only: [:update_full_name]
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

  def update_names
    if request.patch? and @user
        if @user.update(user_params)
          render json: { success: "Profile updated" }, status: :ok
        else
          render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
        end
    end
  end

  def send_mail_verification_otp
    render json: { success: "otp send" }, status: :ok
  end

  def update_email

  end

  def update_password

  end

  private

  def set_user
    @user = User.find(params[:user_id])
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :username )
  end

end