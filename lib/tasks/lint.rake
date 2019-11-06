desc "Run govuk-lint"
task "lint" do
  sh "govuk-lint-ruby --format clang app lib spec test Gemfile"
end
