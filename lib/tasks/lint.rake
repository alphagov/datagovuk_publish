desc "Run rubocop"
task "lint" do
  sh "rubocop --format clang app lib spec test Gemfile"
end
