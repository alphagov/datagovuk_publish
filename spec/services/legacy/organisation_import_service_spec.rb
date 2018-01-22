require 'rails_helper'

describe Legacy::OrganisationImportService do
  let(:legacy_organisation) do
    file_path = Rails.root.join('spec', 'fixtures', 'legacy_organisation.json')
    org_json = File.read(file_path)
    JSON.parse(org_json).with_indifferent_access
  end

  describe "#run" do
    it "builds an organisation from a legacy organisation" do
      Legacy::OrganisationImportService.new(legacy_organisation).run
      imported_organisation = Organisation.find_by(uuid: legacy_organisation["id"])

      expect(imported_organisation.uuid).to eql '12345-6789'
      expect(imported_organisation.name).to eql '2gether-nhs-foundation-trust'
      expect(imported_organisation.title).to eql '2gether NHS Foundation Trust'
      expect(imported_organisation.description).to eql 'Example description'
      expect(imported_organisation.abbreviation).to eql 'ED'
      expect(imported_organisation.replace_by).to eql '[]'

      expect(imported_organisation.contact_email).to eql 'jane.bar@example.com'
      expect(imported_organisation.contact_phone).to eql '3456'
      expect(imported_organisation.contact_name).to eql 'Jane Bar'

      expect(imported_organisation.foi_email).to eql 'jdoe@example.com'
      expect(imported_organisation.foi_phone).to eql '1234'
      expect(imported_organisation.foi_name).to eql 'John Doe'
      expect(imported_organisation.foi_web).to eql 'http://www.example.com'
    end

    it "assigns the organisation type to 'central-government' from relevant set of categories" do
      %w("ministerial-department", "non-ministerial-department",
          "devolved", "executive-ndpb", "advisory-ndpb",
          "tribunal-ndpb", "executive-agency",
          "executive-office", "gov-corporation").each do |category|
            legacy_organisation["category"] = category
            Legacy::OrganisationImportService.new(legacy_organisation).run
            imported_organisation = Organisation.find_by(uuid: legacy_organisation["id"])

            expect(imported_organisation.org_type).to eql 'central-government'
          end
    end

    it "assigns the organisation type to 'local-council' from relevant category" do
      legacy_organisation["category"] = 'local-council'
      Legacy::OrganisationImportService.new(legacy_organisation).run
      imported_organisation = Organisation.find_by(uuid: legacy_organisation["id"])

      expect(imported_organisation.org_type).to eql 'local-authority'
    end

    it "assigns the organisation type to 'other-government-body' from all other categories" do
      legacy_organisation["category"] = 'foo'
      Legacy::OrganisationImportService.new(legacy_organisation).run
      imported_organisation = Organisation.find_by(uuid: legacy_organisation["id"])

      expect(imported_organisation.org_type).to eql 'other-government-body'
    end
  end
end
