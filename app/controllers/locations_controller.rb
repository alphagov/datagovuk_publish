
class LocationsController < ApplicationController
  protect_from_forgery prepend: :true
  before_action :authenticate_user!


  def lookup
    if params[:q]
      @query = params[:q].downcase
      @locations = Location.where("name ILIKE CONCAT('%',:search,'%')", {search: @query})
      @location_strings = @locations.map { | l | l.name + " (" + l.location_type + ")" }
      render json: @location_strings
    else
      render json: []
    end
  end
end
