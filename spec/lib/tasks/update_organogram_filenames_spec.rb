require "rails_helper"
require_relative "../../../lib/tasks/update_organogram_filenames.rb"

describe UpdateOrganogramFilenames do
  before do
    FactoryBot.create(:link, url: "https://s3-eu-west-1.amazonaws.com/datagovuk/dataset/resources/organogram-senior-posts-2019-06-06T11-18-26Z.csv")
    FactoryBot.create(:link, url: "https://s3-eu-west-1.amazonaws.com/datagovuk/dataset/resources/organogram-junior-posts-2019-06-06T11-18-30Z.csv")
    File.write("sample_urls.csv", "https://s3-eu-west-1.amazonaws.com/datagovuk/dataset/resources/organogram-senior-posts-2019-06-06T11-18-26Z.csv, https://s3-eu-west-1.amazonaws.com/datagovuk/dataset/resources/2019-06-06T11-18-26Z-organogram-senior.csv\nhttps://s3-eu-west-1.amazonaws.com/datagovuk/dataset/resources/organogram-junior-posts-2019-06-06T11-18-30Z.csv, https://s3-eu-west-1.amazonaws.com/datagovuk/dataset/resources/2019-06-06T11-18-26Z-organogram-junior.csv")
  end

  after { File.delete("sample_urls.csv") }

  context "when parsing a CSV file" do
    it "should set old_urls and new_urls array if it contains data" do
      update_organogram_filenames = UpdateOrganogramFilenames.new
      update_organogram_filenames.parse_csv("sample_urls.csv")
      expect(update_organogram_filenames.instance_eval { @old_urls }.length).to be(2)
      expect(update_organogram_filenames.instance_eval { @new_urls }.length).to be(2)
    end

    it "should abort and return a message if it's empty" do
      File.write("sample_urls.csv", "")
      update_organogram_filenames = UpdateOrganogramFilenames.new
      update_organogram_filenames.parse_csv("sample_urls.csv")
      expect(update_organogram_filenames.replace_urls).to eql("No urls to process")
    end
  end

  context "when a url containing '-posts-' is found" do
    it "replaces the url with the correct url" do
      update_organogram_filenames = UpdateOrganogramFilenames.new
      update_organogram_filenames.parse_csv("sample_urls.csv")

      update_organogram_filenames.replace_urls

      expect(Link.all.length).to be(2)
      expect(Link.all.map(&:url)).to include(
        "https://s3-eu-west-1.amazonaws.com/datagovuk/dataset/resources/2019-06-06T11-18-26Z-organogram-senior.csv", "https://s3-eu-west-1.amazonaws.com/datagovuk/dataset/resources/2019-06-06T11-18-26Z-organogram-junior.csv"
      )
    end
  end
end
