#!/usr/bin/env ruby

require 'json'

if ARGV.size < 2
  puts "Usage is #{__FILE__} <fly_target> <pipelines.json>"
  exit 1
end

fly_target = ARGV[0]
pipelines_file = ARGV[1]

pipelines_json = JSON.parse(File.read(pipelines_file))

pipelines_json.each do |pipeline|
  unless pipeline['paused']
    `fly -t #{fly_target} unpause-pipeline -p #{pipeline['name']}`
  end
  if pipeline['public']
    `fly -t #{fly_target} expose-pipeline -p #{pipeline['name']}`
  end
end
