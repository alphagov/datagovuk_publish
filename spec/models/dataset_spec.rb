require "rails_helper"

describe Dataset do
  subject { create :dataset, organisation: (create :organisation), status: "draft" }

  it "requires a title and a summary" do
    dataset = Dataset.new(title: "", summary: "")

    dataset.valid?

    expect(dataset.errors[:title]).to include "Please enter a valid title"
    expect(dataset.errors[:summary]).to include "Please provide a summary"
  end

  it "validates title format" do
    dataset = Dataset.new(title: "[][]")

    dataset.valid?
    expect(dataset.errors[:title]).to include "Please enter a valid title"
  end

  it "generates a unique slug and stores it on the name column" do
    dataset = FactoryBot.create(:dataset, title: "My awesome dataset")

    expect(dataset.name).to eq(dataset.title.parameterize)
  end

  it "generates a new slug when the title has changed" do
    dataset = FactoryBot.create(:dataset, uuid: 1234, title: "My awesome dataset")

    dataset.update!(title: "My Even Better Dataset")

    expect(dataset.name).to eq("my-even-better-dataset")
  end

  describe "#publish" do
    it "changes the dataset status to published" do
      subject.publish
      expect(subject.published?).to be_truthy
    end

    it "indexes the document into Elasticsearch" do
      subject.publish
      expect { get_from_es(subject.uuid) }.to_not raise_error
    end

    it "raises an error when the ES index fails" do
      allow(subject.__elasticsearch__).to receive(:index_document)
        .and_return("_shards" => { "failed" => 1 })

      expect { subject.publish }.to_not raise_error(/Failed to publish/)
      expect(subject.reload.published?).to be_falsey
    end
  end

  describe "#unpublish" do
    before do
      subject.publish
    end

    it "changes the dataset status to draft" do
      subject.unpublish
      expect(subject.draft?).to be_truthy
    end

    it "deletes the document from Elasticsearch" do
      subject.unpublish

      expect { get_from_es(subject.uuid) }
        .to raise_error(Elasticsearch::Transport::Transport::Errors::NotFound)
    end

    it "raises an error when the ES delete fails" do
      allow(subject.__elasticsearch__).to receive(:delete_document)
        .and_return("_shards" => { "failed" => 1 })

      expect { subject.unpublish }.to_not raise_error(/Failed to unpublish/)
      expect(subject.published?).to be_truthy
    end
  end
end
