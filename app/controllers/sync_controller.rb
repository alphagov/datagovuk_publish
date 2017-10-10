require 'rake'

class SyncController < ApplicationController
  http_basic_authenticate_with name: ENV["HTTP_USERNAME"], password: ENV["HTTP_PASSWORD"]

  def legacy
    sync_rake
    head :ok
  end

  private

  def sync_rake
    Rake::Task.clear
    log_path = "#{Rails.root}/log/rake.log"
    options = { rails_env: Rails.env }
    args = options.map { |n, v| "#{n.to_s.upcase}='#{v}'" }

    system "rake sync:daily #{args.join(' ')} --trace 2>&1 >> #{log_path} &"
  end
end
