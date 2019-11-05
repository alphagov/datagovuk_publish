require "rails_helper"

describe IndexDeletionService do
  INDEX_CREATED_THIS_MORNING = "datasets-test_20171122070000".freeze
  INDEX_CREATED_YESTERDAY = "datasets-test_20171121070000".freeze
  INDEX_CREATED_LAST_WEEK = "datasets-test_20171112070000".freeze
  INDEX_CREATED_LAST_MONTH = "datasets-test_20171022070000".freeze

  before(:each) do
    @client_double = double("client")
    logger_double = double("logger", info: "")

    index_deleter_args = {
      index_alias: "datasets-#{ENV['RAILS_ENV']}",
      client: @client_double,
      logger: logger_double,
    }

    @index_deleter = IndexDeletionService.new(index_deleter_args)
  end

  describe "when there are more than three indices" do
    it "deletes the correct number of indices" do
      indexes = [
        INDEX_CREATED_THIS_MORNING,
        INDEX_CREATED_YESTERDAY,
        INDEX_CREATED_LAST_WEEK,
        INDEX_CREATED_LAST_MONTH
      ]

      allow(@client_double).to receive_message_chain(:indices, :get_aliases, :keys) { indexes }
      allow(@client_double).to receive_message_chain(:indices, :delete)

      expect(@client_double.indices)
        .to receive(:delete)
        .with(index: INDEX_CREATED_LAST_MONTH)

      @index_deleter.run
    end
  end

  describe "when there are less than three indices" do
    it "deletes the correct number of indices" do
      indexes = [
        INDEX_CREATED_THIS_MORNING,
        INDEX_CREATED_LAST_WEEK,
      ]

      allow(@client_double).to receive_message_chain("indices.get_aliases.keys") { indexes }
      allow(@client_double).to receive_message_chain("indices.delete") { true }

      expect(@client_double)
        .to_not receive(:'indices.delete')

      @index_deleter.run
    end
  end
end
