require 'rails_helper'

describe Link, type: :model do
  before do
    @link = FactoryGirl.create(:link)
  end

  describe 'creation' do
    it 'can be created' do
      expect(@link).to be_valid
    end
  end

  describe 'validations' do
    it 'should have a name' do
      @link.name = nil

      expect(@link).to_not be_valid
    end
  end

  describe 'before saving' do
    it 'should be assigned a uuid if it does not have one' do
      @link.uuid = nil

      @link.save!

      expect(Link.last.uuid).to_not be_nil
    end
  end
end
