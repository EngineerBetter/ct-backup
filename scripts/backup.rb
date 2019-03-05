#!/usr/bin/env ruby

require 'json'

require_relative("lib/concourse.rb")

fly_target = ENV['FLY_TARGET']
admin_password = ENV['ADMIN_PASSWORD']

if fly_target.nil? || admin_password.nil?
    puts 'FLY_TARGET and ADMIN_PASSWORD must be set'
    exit 1
end

output_dir = ENV["OUTPUT_DIR"]

if output_dir.nil?
    `mkdir -p out`
    output_dir = "out"
end

puts 'exporting teams'
teams = `fly -t #{fly_target} teams --json`
File.write("#{output_dir}/teams.json", teams)
teams_json = JSON.parse(teams)

concourse = Concourse.new(fly_target, output_dir, admin_password, teams_json)

concourse.set_teams_with_admin

concourse.export_pipelines

concourse.set_teams_with_auth
