class ProfilePicturesController < ApplicationController
  before_action :set_user

  def create
    @profile_picture = @user.build_profile_picture(profile_picture_params)
    if @profile_picture.save
      render json: { message: 'Profile picture uploaded successfully', url: url_for(@profile_picture.image) }, status: :created
    else
      render json: @profile_picture.errors, status: :unprocessable_entity
    end
  end

  def update
    @profile_picture = @user.profile_picture
    if @profile_picture.update(profile_picture_params)
      render json: { message: 'Profile picture updated successfully', url: url_for(@profile_picture.image) }, status: :ok
    else
      render json: @profile_picture.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @profile_picture = @user.profile_picture
    @profile_picture.destroy
    head :no_content
  end

  private

  def set_user
    @user = User.find(params[:user_id])
  end

  def profile_picture_params
    params.require(:profile_picture).permit(:image)
  end
end