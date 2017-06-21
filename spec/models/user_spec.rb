require 'rails_helper'

describe User do
  it "can create a new User" do
    org = Organisation.create!(name: "land-registry", title: "Land Registry")
    u = User.create(email: "test@localhost",
                    name: "Test User",
                    primary_organisation: org,
                    password: "password",
                    password_confirmation: "password")
    expect(u.save).to eq(true)
    expect(u.organisations.count()).to eq(0)
  end

  it "Users can be added to more than one organisation" do
    org = Organisation.create!(name: "land-registry", title: "Land Registry")
    u = User.create(email: "test@localhost",
                    name: "Test User",
                    primary_organisation: org,
                    password: "password",
                    password_confirmation: "password")
    expect(u.save).to eq(true)
    expect(u.organisations.count()).to eq(0)

    org2 = Organisation.create!(name: "cabinet-office", title: "Cabinet Office")
    org3 = Organisation.create!(name: "home-office", title: "Home Office")

    u.organisations << org2
    u.organisations << org3
    expect(u.organisations.count()).to eq(2)

    expect(u.in_organisation org).to eq(true)
    expect(u.in_organisation org2).to eq(true)
    expect(u.in_organisation org3).to eq(true)
  end
end
