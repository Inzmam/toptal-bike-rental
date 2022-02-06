class UsersController < ApplicationController

  def index
    if params[:role].present?
      @users = User.where(role: params[:role])
    else
      @users = User.all
    end

    render json: { users: @users }, status: 200
  end

  def create
    @user = User.new(user_params)
    @user.password = "admin1234"

    if @user.save!
      if @user.role == "Manager"
        render json: { manager: @user, message: "#{@user.role} Created Successfully" }, status: 200
      elsif @user.role == "User"
        render json: { user: @user, message: "#{@user.role} Created Successfully" }, status: 200
      end
    else
      render json: { message: 'Something Went Wrong' }, status: 500
    end

  end

  def update
    @user = User.find(params[:id])

    if @user.update(user_params)
      if @user.role == "Manager"
        render json: { manager: @user, message: "#{@user.role} Updated Successfully" }, status: 200
      elsif @user.role == "User"
        render json: { user: @user, message: "#{@user.role} Updated Successfully" }, status: 200
      end
    else
      render json: { message: 'Something Went Wrong' }, status: 500
    end

  end

  def show
    @user = User.find_by_id(params[:id])

    if @user.present?
      if @user.role == "Manager"
        render json: { manager: @user, message: "#{@user.role} Updated Successfully" }, status: 200
      elsif @user.role == "User"
        render json: { user: @user, message: "#{@user.role} Updated Successfully" }, status: 200
      end
    else
      render json: { message: 'User not found' }, status: 404
    end
  end

  def destroy
    @user = User.find_by_id(params[:id])

    if @user.destroy
      render json: { message: "#{@user.role} Deleted Successfully" }, status: 200
    else
      render json: { message: 'Something Went Wrong' }, status: 500
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :name, :role)
  end
end
