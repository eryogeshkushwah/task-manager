module Authenticatable
  extend ActiveSupport::Concern

  included do
    include ActionController::HttpAuthentication::Token::ControllerMethods
  end

  def authenticate_user!
    render_unauthorized unless current_user
  end

  def current_user
    @current_user ||= current_session&.user
  end

  def current_session
    @current_session ||= authenticate_with_http_token do |token, _options|
      Session.find_by(token: token)
    end
  end

  private

  def render_unauthorized
    render json: { error: "Unauthorized access. Please login." }, status: :unauthorized
  end
end
