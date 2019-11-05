FactoryBot.define do
  factory :datafile do
    dataset
    url { "http://google.com" }
    name { "My Datafile" }
    format { "CSV" }
    start_date { 1.month.ago }
    end_date { 1.week.ago }
    type { "Datafile" }
  end
end
