require 'rails_helper'

describe Location do
  it "can create a new Location" do
    l = Location.new
    expect(l.save).to eq(true)
  end
end
