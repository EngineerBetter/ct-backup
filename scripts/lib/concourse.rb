class Concourse
    attr_reader :fly_target, :output_dir, :admin_password, :teams_json

    def initialize(fly_target, output_dir, admin_password, teams_json)
      @fly_target = fly_target
      @output_dir = output_dir
      @admin_password = admin_password
      @teams_json = teams_json
    end

    def set_teams_with_admin
        puts "setting admin on all teams"
        teams_json.map do |team|
            next if team['name'] == 'main'
            flags = set_auth_flags(team)
            flags.push("--local-user=admin", '--non-interactive', "--team-name=#{team['name']}")
            call_fly('set-team', flags)
        end
    end

    def set_teams_with_auth
        puts "setting correct auth on all teams"
        teams_json.map do |team|
            next if team['name'] == 'main'
            flags = set_auth_flags(team)
            flags.push('--non-interactive', "--team-name=#{team['name']}")
            call_fly('set-team', flags)
        end
    end

    def export_pipelines
        puts "exporting pipelines"
        `mkdir -p #{output_dir}/pipelines`
        teams_json.each do |team|
            name = team['name']
            call_fly('login', ["--password=#{admin_password}", "--username=admin", "--team-name=#{name}", '-k'])
            pipelines = JSON.parse(call_fly('pipelines', ['--json']))
            pipelines.each do |pipeline|
                next if pipeline['name'] == 'concourse-up-self-update'
                pipeline_yaml = call_fly('get-pipeline', ["--pipeline=#{pipeline['name']}"])
                write_file("#{output_dir}/pipelines/#{name}-#{pipeline['name']}.yml", pipeline_yaml)
            end
        end
    end

    def import_pipelines
        puts "importing pipelines"
        get_files("#{output_dir}/pipelines").each do |file|
            if file=='.' || file=='..' then next end
            team = file.split("-")[0]
            pipeline = file.split("-")[1..-1].join('-').sub('.yml', '')
            call_fly('login', ["--password=#{admin_password}", "--username=admin", "--team-name=#{team}", '-k'])
            call_fly('set-pipeline', ["--config=#{output_dir}/pipelines/#{file}", "--pipeline=#{pipeline}", '--non-interactive'])
        end
    end

    private

    def call_fly(command, flags)
        `fly -t #{fly_target} #{command} #{flags.join(' ')}`
    end

    def write_file(path, contents)
        File.write(path, contents)
    end

    def get_files(dir)
        Dir.entries(dir)
    end

    def set_auth_flags(team)
        flags = []
        groups = team['auth']['groups']
        users = team['auth']['users']

        groups.each do |group|
            arr = group.split(':')
            if arr.size == 3
                flags.push("--github-team=#{arr[1]}:#{arr[2]}")
            elsif arr.size == 2
                flags.push("--github-org=#{arr[1]}")
            end
        end

        users.each do |user|
            arr = user.split(':')
            if arr[0] == 'github'
                flags.push("--github-user=#{arr[1]}")
            elsif arr[0] == 'local'
                flags.push("--local-user=admin")
            end
        end
        flags
    end
  end
