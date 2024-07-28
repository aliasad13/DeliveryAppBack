class AuthenticationController < ApplicationController
  skip_before_action :authenticate_request, only: [:refresh, :register, :login]

  def register
    @user = User.new(user_params)
    if @user.save
      tokens = create_tokens(@user)
      render json: { accessToken: tokens[:access_token], refreshToken: tokens[:refresh_token], user: @user }, status: :created
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def login
    @user = User.find_by('email = :login OR username = :login', login: params[:email])
    if @user&.authenticate(params[:password])
      tokens = create_tokens(@user)
      render json: { accessToken: tokens[:access_token], refreshToken: tokens[:refresh_token], username: @user.username }, status: :ok
    else
      render json: { errors: ['Invalid email or password'] }, status: :unauthorized
    end
  end

  def refresh #refresh token in removed from authenticated becs refresh token dont have to look at expiration time.
    # the only requests to refresh endpoint is to renew the expired tokens
    if request.headers.present? and request.headers['Authorization']
    header = request.headers['Authorization']
    refresh_token = header.split(' ').last if header
    if refresh_token != 'null'
      decoded = JsonWebToken.decode(refresh_token)
      decoded = nil
      if decoded.nil?
        render json: { errors: ['Invalid token'] }, status: :unauthorized
      else
        @user = User.find(decoded[:user_id])
        tokens = create_tokens(@user)
        render json: { accessToken: tokens[:access_token], refreshToken: tokens[:refresh_token] }, status: :ok
      end
    else
      render json: { errors: ['Invalid token'] }, status: :unauthorized
    end
    else
      render json: { errors: ['Header/Token absent'] }, status: :unauthorized
    end
  end

  def logout
    # Here you might want to invalidate the refresh token
    # This depends on how you're storing refresh tokens
    render json: { message: 'Logged out successfully' }, status: :ok
  end

  private

  def user_params
    params.require(:authentication).permit(:username, :email, :password, :password_confirmation, :confirm_success_url)
  end

  def create_tokens(user)
    {
      access_token: JsonWebToken.encode(user_id: user.id),
      refresh_token: JsonWebToken.encode_refresh_token(user.id)
    }
  end
end