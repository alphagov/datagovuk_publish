require "rails_helper"

describe IndexDeletionService do
  index_created_this_morning = "datasets-test_20171122070000".freeze
  index_created_yesterday = "datasets-test_20171121070000".freeze
  index_created_last_week = "datasets-test_20171112070000".freeze
  index_created_last_month = "datasets-test_20171022070000".freeze

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
        index_created_this_morning,
        index_created_yesterday,
        index_created_last_week,
        index_created_last_month,
      ]

      allow(@client_double).to receive_message_chain(:indices, :get_alias, :keys) { indexes }
      allow(@client_double).to receive_message_chain(:indices, :delete)

      expect(@client_double.indices)
        .to receive(:delete)
        .with(index: index_created_last_month)

      @index_deleter.run
    end
  end

  describe "when there are less than three indices" do
    it "deletes the correct number of indices" do
      indexes = [
        index_created_this_morning,
        index_created_last_week,
      ]

      allow(@client_double).to receive_message_chain("indices.get_alias.keys") { indexes }
      allow(@client_double).to receive_message_chain("indices.delete") { true }

      expect(@client_double)
        .to_not receive(:'indices.delete')

      @index_deleter.run
    end
  end
end
