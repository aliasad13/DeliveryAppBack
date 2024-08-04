class UsersController < ApplicationController


  before_action :set_user, only: [:update_names, :update_password, :update_profile_picture]
  before_action :user_params, only: [:update_names, :update_password]
  before_action :profile_picture_params, only: [:update_profile_picture]


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
            user_data[:profile_picture] = url_for(current_user.profile_picture.image) if current_user.profile_picture&.image.attached?
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

  def update_profile_picture
    if @user.profile_picture
      @user.profile_picture.update(profile_picture_params)
    else
      @user.create_profile_picture(profile_picture_params)
    end

    if @user.save
      render json: { message: 'Profile picture updated successfully', url: url_for(@user.profile_picture.image) }, status: :ok
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
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
      current_password = user_params[:current_password]
      new_password = user_params[:new_password]

      if @user.authenticate(current_password)
        if @user.update(password: new_password)
          render json: { message: 'Password updated successfully' }, status: :ok
        else
          render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
        end
      else
        render json: { error: 'Current password is incorrect' }, status: :unauthorized
      end
    end

  private

  def set_user
    @user = User.find_by(id: params[:user_id]) || User.find_by(id: params[:id])
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :username, :new_password, :current_password, :profile_picture_attributes ) if params[:user].present?
    params.permit( :new_password, :current_password, :user_id ) if !params[:user].present?
  end

  def parameters
    params.permit( :new_password, :current_password, :user_id )
  end

  def profile_picture_params
    params.require(:user).require(:profile_picture_attributes).permit(:image)
  end

end