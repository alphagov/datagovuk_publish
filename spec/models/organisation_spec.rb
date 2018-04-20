require 'rails_helper'

describe Organisation do
  it "can create a new dataset" do
    o = Organisation.new
    o.title = "A test organisation"
    o.name = "a-test-organisation"

    expect(o.save).to eq(true)
    expect(o.active?).to eq(true)
    expect(o.closed?).to eq(false)
  end

  it "can generate unique slugs" do
    o = Organisation.new
    o.title = "A test organisation"
    expect(o.save).to eq(true)

    o2 = Organisation.new
    o2.title = "A test organisation"
    expect(o2.save).to eq(true)

    expect(o2.name).to eq("a-test-organisation-2")
  end


  it "can register and deregister users" do
    o = Organisation.new
    o.title = "A test organisation"
    expect(o.save).to eq(true)

    u = User.create(email: "test@localhost",
                    name: "Test User",
                    primary_organisation: o,
                    password: "password",
                    password_confirmation: "password")

    o.destroy
    u.reload

    expect(u.primary_organisation).to eq(nil)
  end
end
