class LocationsController < ApplicationController
  protect_from_forgery prepend: :true
  before_action :authenticate_user!

  def lookup
    if params[:q]
      @query = params[:q].downcase
      @locations = Location.where("name ILIKE CONCAT('%',:search,'%')", {search: @query})
      @location_strings = @locations.map { |x| format_location x }
      render json: @location_strings
    else
      render json: []
    end
  end

  private

  def format_location(l)
    result = l.name
    if l.location_type && l.location_type != ""
      result += " (#{l.location_type})"
    end
    result
  end
end
