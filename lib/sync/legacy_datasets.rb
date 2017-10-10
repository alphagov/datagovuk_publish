require 'rake'

class LegacyDataSync
  def run
    Rake::Task.clear
    log_path = "#{Rails.root}/log/rake.log"
    options = { rails_env: Rails.env }
    args = options.map { |n, v| "#{n.to_s.upcase}='#{v}'" }

    system "rake sync:daily #{args.join(' ')} --trace 2>&1 >> #{log_path} &"
  end
end
