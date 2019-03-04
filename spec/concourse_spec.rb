require "rspec"
require 'json'
require_relative "../lib/concourse"

describe Concourse do

    before do
        teams_json = JSON.parse(File.read("#{RSPEC_ROOT}/fixtures/teams.json"))
        @concourse = Concourse.new("target", "output_dir", "password", teams_json)
    end
    describe 'set_teams_with_admin' do
        before do
            expect(@concourse).to receive(:call_fly).with('set-team', ["--github-user=engineerbetterci", "--local-user=admin", "--local-user=admin", "--non-interactive", "--team-name=test"]).ordered.and_return("success1")
            expect(@concourse).to receive(:call_fly).with('set-team', ["--github-org=ebciaccess", "--local-user=admin", "--non-interactive", "--team-name=test2"]).ordered.ordered.and_return("success2")
            expect(@concourse).to receive(:call_fly).with('set-team', ["--github-user=engineerbetterci", "--local-user=admin", "--non-interactive", "--team-name=test3"]).ordered.ordered.and_return("success3")
        end

        it "should succeed for all the teams" do
            output = @concourse.set_teams_with_admin
            expect(output.size).to equal(4)
            expect(output).to include("success1", "success2", "success3")
        end
    end

    describe 'set_teams_with_auth' do
        before do
            expect(@concourse).to receive(:call_fly).with('set-team', ["--github-user=engineerbetterci", "--local-user=admin", "--non-interactive", "--team-name=test"]).ordered.and_return("success1")
            expect(@concourse).to receive(:call_fly).with('set-team', ["--github-org=ebciaccess", "--non-interactive", "--team-name=test2"]).ordered.ordered.and_return("success2")
            expect(@concourse).to receive(:call_fly).with('set-team', ["--github-user=engineerbetterci", "--non-interactive", "--team-name=test3"]).ordered.ordered.and_return("success3")
        end

        it "should succeed for all the teams" do
            output = @concourse.set_teams_with_auth
            expect(output.size).to equal(4)
            expect(output).to include("success1", "success2", "success3")
        end
    end

    describe 'export_pipelines' do
        before do
            pipelines1 = File.read("#{RSPEC_ROOT}/fixtures/pipelines1.json")
            pipelines2 = File.read("#{RSPEC_ROOT}/fixtures/pipelines2.json")
            pipelines3 = File.read("#{RSPEC_ROOT}/fixtures/pipelines_empty.json")
            pipelines4 = pipelines3
            expect(@concourse).to receive(:`).and_return("created dir")
            expect(@concourse).to receive(:call_fly).with('login', ["--password=password", "--username=admin", "--team-name=main", "-k"]).ordered
            expect(@concourse).to receive(:call_fly).with('pipelines', ["--json"]).ordered.and_return(pipelines1)
            expect(@concourse).to receive(:call_fly).with('get-pipeline', ["--pipeline=weave-scope"]).ordered.and_return("weave-scope-contents")
            expect(@concourse).to receive(:write_file).with("output_dir/pipelines/main-weave-scope.yml", "weave-scope-contents")
            expect(@concourse).to receive(:call_fly).with('get-pipeline', ["--pipeline=credhub-backup"]).ordered.and_return("credhub-backup-contents")
            expect(@concourse).to receive(:write_file).with("output_dir/pipelines/main-credhub-backup.yml", "credhub-backup-contents")
            expect(@concourse).to receive(:call_fly).with('get-pipeline', ["--pipeline=influxdb-boshrelease"]).ordered.and_return("influxdb-boshrelease-contents")
            expect(@concourse).to receive(:write_file).with("output_dir/pipelines/main-influxdb-boshrelease.yml", "influxdb-boshrelease-contents")
            expect(@concourse).to receive(:call_fly).with('login', ["--password=password", "--username=admin", "--team-name=test", "-k"]).ordered
            expect(@concourse).to receive(:call_fly).with('pipelines', ["--json"]).ordered.and_return(pipelines2)
            expect(@concourse).to receive(:call_fly).with('get-pipeline', ["--pipeline=hello"]).ordered.and_return("hello-contents")
            expect(@concourse).to receive(:write_file).with("output_dir/pipelines/test-hello.yml", "hello-contents")
            expect(@concourse).to receive(:call_fly).with('login', ["--password=password", "--username=admin", "--team-name=test2", "-k"]).ordered
            expect(@concourse).to receive(:call_fly).with('pipelines', ["--json"]).ordered.and_return(pipelines3)
            expect(@concourse).to receive(:call_fly).with('login', ["--password=password", "--username=admin", "--team-name=test3", "-k"]).ordered
            expect(@concourse).to receive(:call_fly).with('pipelines', ["--json"]).ordered.and_return(pipelines4)
        end

        it "should export all the pipelines for each team" do
            @concourse.export_pipelines
        end
    end

    describe 'import_pipelines' do
        before do
            expect(@concourse).to receive(:get_files).with('output_dir/pipelines').and_return(["main-pipeline.yml", "test-hello.yml"])
            expect(@concourse).to receive(:call_fly).with('login', ["--password=password", "--username=admin", "--team-name=main", "-k"]).ordered
            expect(@concourse).to receive(:call_fly).with('set-pipeline', ["--config=output_dir/pipelines/main-pipeline.yml", "--pipeline=pipeline", "--non-interactive"]).ordered
            expect(@concourse).to receive(:call_fly).with('login', ["--password=password", "--username=admin", "--team-name=test", "-k"]).ordered
            expect(@concourse).to receive(:call_fly).with('set-pipeline', ["--config=output_dir/pipelines/test-hello.yml", "--pipeline=hello", "--non-interactive"]).ordered
        end

        it "should import all the pipelines" do
            @concourse.import_pipelines
        end
    end
end
