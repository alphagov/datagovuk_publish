desc "Run govuk-lint on all files"
task "lint" do
  if ENV["CI"]
    sh "govuk-lint-ruby --diff --cached --format html --out govuk-lint-ruby-${GIT_COMMIT}.html --format clang"
  else
    sh "govuk-lint-ruby --diff --cached --format clang"
  end
end

Rake::Task[:default].enhance %i(lint)
