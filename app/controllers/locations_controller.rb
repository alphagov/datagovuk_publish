
class LocationsController < ApplicationController
  protect_from_forgery prepend: :true
  before_action :authenticate_user!

  def lookup
    Location.all
  end
end
