class ApplicationController < ActionController::Base
  include GDS::SSO::ControllerMethods

  protect_from_forgery with: :exception
  before_action :set_raven_context
  before_action :authenticate_user!
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

private

  def record_not_found
    render plain: '404 Not Found', status: 404
  end

  def set_raven_context
    Raven.user_context(id: current_user&.id,
                       name: current_user&.name,
                       email: current_user&.email,
                       organisation_slug: current_user&.organisation_slug,
                       organisation_content_id: current_user&.organisation_content_id)

    Raven.extra_context(params: params.to_unsafe_h,
                        url: request.url,
                        environment: Rails.env,
                        app_environment: ENV['VCAP_APPLICATION'])
  end
end
