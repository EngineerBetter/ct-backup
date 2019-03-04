require 'yaml'

def set_credentials(input)
  creds = YAML.safe_load(input)
  puts 'beginning credhub import - this may take a while'
  creds['credentials'].each do |cred|
    name = cred['name']
    type = cred['type']
    value = cred['value']

    puts "importing #{name}"

    case type
    when 'password'
      `credhub set --name=#{name} --type=#{type} --password='#{value}'`
    when 'user'
      `credhub set --name=#{name} --type=#{type} ---username='#{value['username']}' --password='#{value['password']}'`
    when 'rsa'
      `credhub set --name=#{name} --type=#{type} --private='#{value['private_key']}' --public='#{value['public_key']}'`
    when 'certificate'
      `credhub set --name=#{name} --type=#{type} --ca-name='#{value['ca']}' --certificate='#{value['certificate']}' --private='#{value['private_key']}'`
    when 'ssh'
      `credhub set --name=#{name} --type=#{type} --private='#{value['private_key']}' --public='#{value['public_key']}'`
    else
      # Covers value and json type
      `credhub set --name=#{name} --type=#{type} --value='#{value}'`
    end
  end
end
