class ApplicationController < ActionController::API
  include Authenticatable

  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :render_record_invalid
  rescue_from ActionController::ParameterMissing, with: :render_parameter_missing

  private

  def render_not_found(exception)
    render json: { error: "#{exception.model} not found"  }, status: :not_found
  end

  def render_record_invalid(exception)
    render json: { errors: exception.record.errors.full_messages }, status: :unprocessable_entity
  end

  def render_parameter_missing(exception)
    render json: { error: exception.message }, status: :bad_request
  end
end
