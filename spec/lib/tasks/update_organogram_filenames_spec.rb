require 'rails_helper'
require_relative '../../../lib/tasks/update_organogram_filenames.rb'

describe UpdateOrganogramFilenames do
  before do
    @link1 = FactoryBot.create(:link, url: "https://amazonaws.com/datagovuk/dataset/resources/organogram-senior-posts-2019-06-06T11-18-26Z.csv")
    @link2 = FactoryBot.create(:link, url: "https://amazonaws.com/datagovuk/dataset/resources/organogram-junior-posts-2019-06-06T11-18-30Z.csv")
    File.write("sample_urls.csv", "https://amazonaws.com/datagovuk/dataset/resources/organogram-senior-posts-2019-06-06T11-18-26Z.csv, https://amazonaws.com/datagovuk/dataset/resources/2019-06-06T11-18-26Z-organogram-senior.csv\nhttps://amazonaws.com/datagovuk/dataset/resources/organogram-junior-posts-2019-06-06T11-18-30Z.csv, https://amazonaws.com/datagovuk/dataset/resources/2019-06-06T11-18-26Z-organogram-junior.csv")
  end

  context "when parsing a CSV file" do
    it "should return an array if it contains data" do
      update_organogram_filenames = UpdateOrganogramFilenames.new
      expect(update_organogram_filenames.parse_csv("sample_urls.csv")).to be_an_instance_of(Array)
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

      expect(Link.all[0].url).to eql("https://amazonaws.com/datagovuk/dataset/resources/2019-06-06T11-18-26Z-organogram-senior.csv")
      expect(Link.all[1].url).to eql("https://amazonaws.com/datagovuk/dataset/resources/2019-06-06T11-18-26Z-organogram-junior.csv")
    end
  end
end
