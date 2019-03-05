#!/usr/bin/env ruby

require 'json'

require_relative("lib/concourse.rb")

concourse_url = ENV['CONCOURSE_URL']
admin_password = ENV['ADMIN_PASSWORD']

if concourse_url.nil? || admin_password.nil?
    puts 'CONCOURSE_URL and ADMIN_PASSWORD must be set'
    exit 1
end

`fly -t restore login -k -c #{concourse_url} -u admin -p #{admin_password}`

backup_source_dir = 'backup_source'

unless FileTest.exist?("#{backup_source_dir}/teams.json")
    puts "teams.json not present in #{backup_source_dir}"
    exit 1
end

teams_json = JSON.parse(File.read("#{backup_source_dir}/teams.json"))

concourse = Concourse.new('restore', backup_source_dir, admin_password, teams_json)

concourse.set_teams_with_admin

concourse.import_pipelines

concourse.set_teams_with_auth
