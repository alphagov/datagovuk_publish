require "rails_helper"

describe AliasUpdaterService do
  let(:client) { double :client }

  subject do
    described_class.new(
      new_index_name: "new_index",
      index_alias: "my_alias",
      client: client,
      logger: Rails.logger)
  end

  describe "#run" do
    before do
      allow(client).to receive_message_chain("indices.get_aliases") do
        { "other_index" => { "aliases" => {} },
          "current_index" => { "aliases" => { "my_alias" => {} } },
          "other_alias" => { "aliases" => { "other_alias" => {} } } }
      end
    end

    it "repoints the alias to the new index" do
      expected = { body: {
        actions: [
          { remove: { index: "current_index", alias: "my_alias" } },
          { add: { index: "new_index", alias: "my_alias" } },
        ],
      } }

      expect(client).to receive_message_chain("indices.update_aliases")
        .with(expected)

      subject.run
    end
  end
end
