require 'rails_helper'

RSpec.describe HomeController, type: :controller do
  describe "GET #index" do
    it "returns http success" do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      get :index
      expect(response).to have_http_status(:success)
    end
  end

end
