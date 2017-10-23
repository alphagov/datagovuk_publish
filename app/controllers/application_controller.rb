class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  rescue_from CanCan::AccessDenied do |exception|
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
end
