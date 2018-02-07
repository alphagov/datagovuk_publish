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

      task = Task.last

      expect(task.organisation_id).to eql link.dataset.organisation_id
      expect(task.owning_organisation).to eql link.dataset.organisation.name
      expect(task.required_permission_name).to eql ""
      expect(task.category).to eql "broken"
      expect(task.quantity).to eql 1
      expect(task.related_object_id).to eql link.dataset.uuid
      expect(task.description).to eql %('#{link.dataset.title}' contains broken links)
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
