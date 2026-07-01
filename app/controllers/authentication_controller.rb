class AuthenticationController < ApplicationController
  # Ensure we only authenticate on logout
  before_action :authenticate_user!, only: [:logout]

  # POST /auth/register
  def register
    service = Authentication::RegisterService.new(register_params)
    result = service.call

    if result.success?
      render json: {
        message: "User registered successfully.",
        user: result.data
      }, status: :created
    else
      render json: { errors: result.errors }, status: :unprocessable_entity
    end
  end

  # POST /auth/login
  def login
    service = Authentication::LoginService.new(
      email: params[:email],
      password: params[:password],
      user_agent: request.user_agent,
      ip_address: request.remote_ip
    )
    result = service.call

    if result.success?
      render json: {
        message: "Login successful.",
        token: result.data[:session].token,
        user: result.data[:user]
      }, status: :ok
    else
      render json: { errors: result.errors }, status: :unauthorized
    end
  end

  # DELETE /auth/logout
  def logout
    if current_session.destroy
      render json: { message: "Logged out successfully." }, status: :ok
    else
      render json: { errors: ["Unable to terminate session."] }, status: :unprocessable_entity
    end
  end

  private

  def register_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
