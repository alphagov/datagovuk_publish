class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  if [Rails.env.production?, ENV["HTTP_USERNAME"], ENV["HTTP_PASSWORD"]].all?
      http_basic_authenticate_with name: ENV["HTTP_USERNAME"], password: ENV["HTTP_PASSWORD"]
  end

  private

  def record_not_found
    render plain: "404 Not Found", status: 404
  end
end
