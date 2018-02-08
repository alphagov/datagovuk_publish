require 'rails_helper'

describe LinkCheckerService do
  describe '#run' do
    it 'detects a broken link' do
      link = FactoryGirl.create(:link, url: "http://www.brokenlink.com")
      service = described_class.new(link)

      stub_request(:head, link.url).to_return(status: 404)

      service.run

      expect(link.reload).to be_broken
    end

    it 'creates a broken link task' do
      link = FactoryGirl.create(:link, url: "http://www.brokenlink.com")
      service = described_class.new(link)

      stub_request(:head, link.url).to_return(status: 404)

      service.run

      expect(Task.last)
        .to have_attributes(
          organisation_id: link.dataset.organisation_id,
          owning_organisation: link.dataset.organisation.name,
          required_permission_name: be_blank,
          category: "broken",
          quantity: 1,
          related_object_id: link.dataset.uuid,
          description: "404 Not Found"
          )
    end

    it 'saves the attributes of a valid link' do
      link = FactoryGirl.create(:link, url: "http://www.validlink.com")
      service = described_class.new(link)

      stub_request(:head, link.url).to_return(
        status: 200,
        headers: {
          'Content-Type' => 'text/html; charset=utf-8',
          'Content-Length' => 3
        }
      )

      service.run

      expect(link).not_to be_broken
      expect(link.format).to eql "HTML"
      expect(link.size).to eql 3
      expect(link.last_check).to be_present
    end
  end
end
