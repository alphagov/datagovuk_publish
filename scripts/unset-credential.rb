#!/usr/local/bin/ruby -w
require 'json'

APP, KEY = ARGV[0], ARGV[1]

def app_env
  `cf env #{APP}`
end

def sys_env_json
  app_env.split('System-Provided:').last.split("{\n \"VCAP_APP").first.chomp
end

def sys_env
  JSON.parse(sys_env_json)
end

def secret_service
  @secret_service ||= sys_env["VCAP_SERVICES"]["user-provided"].select do |s|
    s["name"].include?("secret")
  end.first
end

def creds
  secret_service["credentials"]
end

def key_not_found?
  !creds.has_key?(KEY)
end

def delete_cred
  creds.delete(KEY)
end

def user_response
  STDIN.gets.chomp.downcase
end

def user_cancels?
  !%w(y yes).include?(user_response)
end

def creds_dump
  JSON.dump(creds)
end

def update_user_provided_secrets
  `cf uups #{secret_service["name"]} -p '#{creds_dump}'`
end

puts "Got application env, detecting credentials service name ..."
puts "Reading env from '#{APP}' ..."
puts "Using secrets service '#{secret_service["name"]}'"

if key_not_found?
  puts "Error: no key found for #{KEY}."
  exit
end

puts "Are you sure you want to delete #{KEY} from #{secret_service["name"]}? [yN]"

if user_cancels?
  puts "Aborting ..."
  exit
end

puts "\nDeleting credential #{KEY} on #{secret_service["name"]}..."

delete_cred
update_user_provided_secrets
