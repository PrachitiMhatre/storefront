class UsersController < ApplicationController
  before_action :authenticate_user!

  def custom_sign_out
    sign_out(current_user)
    redirect_to root_path, notice: "Signed out successfully from controller."
  end
end
