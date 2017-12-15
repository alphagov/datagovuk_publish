require 'rails_helper'

describe IndexDeletionService do
  it 'deletes all indexes except the three most recent' do
    client_double = double('client')
    logger_double = double('logger', info: '')

    index_from_this_morning = 'datasets-test_20171122070000'
    index_from_yesterday = 'datasets-test_20171121070000'
    index_from_last_week = 'datasets-test_20171112070000'
    index_from_last_month = 'datasets-test_20171022070000'
    legacy_index = 'datasets-development'

    indexes = [
      index_from_this_morning,
      index_from_yesterday,
      index_from_last_week,
      index_from_last_month
    ]

    indexes_to_keep = indexes.select { |index| index != index_from_this_morning }

    index_deleter_args = {
      index_alias: "datasets-#{ENV['RAILS_ENV']}",
      client: client_double,
      logger: logger_double
    }

    allow(client_double).to receive_message_chain('indices.get_aliases.keys') { indexes }
    allow(client_double).to receive_message_chain('indices.delete') { true }

    index_deleter = IndexDeletionService.new(index_deleter_args)

    index_deleter.run

    expect(client_double)
      .to receive(:'indices.delete')
      .with(indexes_to_keep)
      .never

    expect(client_double)
      .to_not receive(:'indices.delete')
      .with([index_from_this_morning, legacy_index])
  end
end
