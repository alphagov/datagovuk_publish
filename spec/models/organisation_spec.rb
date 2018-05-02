require 'rails_helper'

describe Organisation do
  it "can generate unique slugs" do
    o = Organisation.new
    o.title = "A test organisation"
    expect(o.save).to eq(true)

    o2 = Organisation.new
    o2.title = "A test organisation"
    expect(o2.save).to eq(true)

    expect(o2.name).to eq("a-test-organisation-2")
  end
end
