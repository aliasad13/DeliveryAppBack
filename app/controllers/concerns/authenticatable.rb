module Authenticatable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_request
    attr_reader :current_user
  end

  private


  def authenticate_request
    if request.headers.present? and request.headers['Authorization']
      header = request.headers['Authorization']
      token = header.split(' ').last if header
      if token != 'null'
        begin
          decoded = JsonWebToken.decode(token)
          if decoded
            if decoded[:exp] && Time.at(decoded[:exp]) < Time.now
              render json: { errors: 'Token has expired' }, status: :unauthorized
            elsif decoded[:user_id]
              current_user = User.find_by(id: decoded[:user_id])
              if current_user
                #donot provide any response here, if no response is provided it will move on to the required action,
                # if you provide a response like render json, it will render that only
              else
                render json: { errors: 'No user record found' }, status: :unauthorized
              end
            else
              render json: { errors: 'Invalid Token' }, status: :unauthorized
            end
          else
            render json: { errors: 'Invalid token' }, status: :unauthorized
          end
        rescue ActiveRecord::RecordNotFound => e
          render json: { errors: e.message }, status: :unauthorized
        rescue JWT::DecodeError => e
          render json: { errors: e.message }, status: :unauthorized
        end
      else
        render json: { errors: 'Token is null' }, status: :unauthorized
      end
    else
      render json: { errors: 'Authorization header missing' }, status: :unauthorized
    end
  end

end

