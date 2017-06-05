class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  if [Rails.env.production?, ENV["HTTP_USERNAME"], ENV["HTTP_PASSWORD"]].all?
      http_basic_authenticate_with name: ENV["HTTP_USERNAME"], password: ENV["HTTP_PASSWORD"]
  end

end
