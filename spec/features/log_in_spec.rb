require "rails_helper"

describe "logging in" do
  let(:land_registry) { FactoryBot.create(:organisation, name: "land-registry", title: "Land Registry") }
  let!(:user) { FactoryBot.create(:user, primary_organisation: land_registry) }

  it "redirects logged in users to the manage page" do
    sign_in_as(user)
    expect(page).to have_current_path "/manage"
  end

  it "requires a user to login to view most pages" do
    sign_out
    expect { visit "/manage" }.to raise_error(/no test user found/)
  end

  it "does not require login for the home page" do
    sign_out
    expect { visit "/" }.to_not raise_error
  end

  it "logs out by redirecting to GOV.UK signon" do
    sign_in_as(user)
    expect(find("a", text: "Sign out")["href"]).to eq gds_sign_out_url
  end
end
