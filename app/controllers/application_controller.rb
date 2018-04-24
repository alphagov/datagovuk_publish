class ApplicationController < ActionController::Base
  include GDS::SSO::ControllerMethods

  protect_from_forgery with: :exception
  before_action :authenticate_user!
  before_action :set_raven_context
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  rescue_from CanCan::AccessDenied do
    respond_to do |format|
      format.json { head :forbidden, content_type: 'text/html' }
      format.html { render plain: '403 Forbidden', status: :forbidden }
      format.js   { head :forbidden, content_type: 'text/html' }
    end
  end

  if Rails.env.production? || Rails.env.staging?
    http_basic_authenticate_with name: ENV["HTTP_USERNAME"], password: ENV["HTTP_PASSWORD"]
  end

private

  def record_not_found
    render plain: '404 Not Found', status: 404
  end

  def set_raven_context
    Raven.user_context(id: current_user&.id,
                       name: current_user &.name,
                       email: current_user&.email,
                       organisation_id: current_user&.primary_organisation&.id,
                       organisation: current_user&.primary_organisation&.name)

    Raven.extra_context(params: params.to_unsafe_h,
                        url: request.url,
                        environment: Rails.env,
                        app_environment: ENV['VCAP_APPLICATION'])
  end
end
