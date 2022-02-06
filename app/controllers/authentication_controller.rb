class AuthenticationController < ApplicationController
  skip_before_action :authenticate_request

  def reset_password
    @user = User.find_by(email: params[:email])

    if @user.present?
      if @user.update(password: params[:password])
        command = AuthenticateUser.call(@user.email, @user.password)
        render json: { auth_token: command.result, role: @user.role, id: @user.id }
      else
        render json: { message: 'Something Went Wrong' }, status: 500
      end
    else
      render json: { message: 'Email does not exist' }, status: 404
    end
  end

  def signup
    old_user = User.find_by(email: params[:email])

    if old_user.present?
      render json: { message: 'Email already exists' }, status: 500
    else
      @user = User.new(email: params[:email], password: params[:password], name: params[:name], role: 'User')

      if @user.save
        command = AuthenticateUser.call(@user.email, @user.password)
        render json: { auth_token: command.result, role: @user.role, id: @user.id }
      else
        render json: { message: 'Something Went Wrong' }, status: 500
      end
    end
  end

  def authenticate
    command = AuthenticateUser.call(params[:email], params[:password])

    if command.success?
      current_user = User.find_by(email: params[:email])
      render json: { auth_token: command.result, role: current_user.role, id: current_user.id }
    else
      render json: { error: command.errors }, status: :unauthorized
    end
  end
end
