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

  describe 'after initializing' do
    it "generates a unique short_id upon initialising" do
      expect(@link.short_id).to_not be_nil 
    end

    it "continues to generate short_ids until it has found a unique one" do
      short_id = '123abc'
      unique_short_id = 'unique'

      allow(SecureRandom).to receive(:urlsafe_base64).and_return(short_id, short_id, unique_short_id)

      FactoryGirl.create(:link)
      new_link = Link.new

      expect(new_link.short_id).to eq(unique_short_id)
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
