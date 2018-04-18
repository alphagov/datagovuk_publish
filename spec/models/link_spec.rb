require 'rails_helper'

describe Link do
  subject { FactoryGirl.create :link }

  describe 'before saving' do
    it 'should be assigned a uuid if it does not have one' do
      subject.uuid = nil
      subject.save!
      subject.reload

      expect(subject.uuid).to_not be_nil
    end
  end
end
