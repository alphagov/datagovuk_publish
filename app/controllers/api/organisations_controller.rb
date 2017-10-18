class OrganisationsController < ApplicationController
  protect_from_forgery prepend: :true

  def lookup
    if params[:q]
      @query = params[:q].downcase
      @organisations = Organisation.where("title ILIKE CONCAT('%',:search,'%')", {search: @query})
    else
      @organisations = Organisation.all
    end

    render json: @organisations.select('id, name, title, abbreviation')
  end
end
