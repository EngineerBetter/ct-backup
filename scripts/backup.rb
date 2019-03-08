#!/usr/bin/env ruby

require 'json'

require_relative("lib/concourse.rb")

concourse_url = ENV['CONCOURSE_URL']
admin_password = ENV['ADMIN_PASSWORD']

if concourse_url.nil? || admin_password.nil?
    puts 'CONCOURSE_URL and ADMIN_PASSWORD must be set'
    exit 1
end

`fly -t backup login -k -c #{concourse_url} -u admin -p #{admin_password}`

`fly -t backup sync`

output_dir = 'out'

puts 'exporting teams'
teams = `fly -t backup teams --json`
File.write("#{output_dir}/teams.json", teams)
teams_json = JSON.parse(teams)

concourse = Concourse.new('backup', output_dir, admin_password, teams_json)

concourse.set_teams_with_admin

concourse.export_pipelines

concourse.set_teams_with_auth
