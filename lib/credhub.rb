require 'yaml'

def set_credentials(input)
  creds = YAML.safe_load(input)
  creds['credentials'].each do |cred|
    name = cred['name']
    type = cred['type']
    value = cred['value']

    puts "importing #{name}"

    if type == 'password'
      `credhub set --name=#{name} --type=#{type} --password='#{value}'`
    elsif type == 'rsa'
      `credhub set --name=#{name} --type=#{type} --private='#{value['private_key']}' --public='#{value['public_key']}'`
    elsif type == 'certificate'
      `credhub set --name=#{name} --type=#{type} --ca-name='#{value['ca']}' --certificate='#{value['certificate']}' --private='#{value['private_key']}'`
    elsif type == 'ssh'
      `credhub set --name=#{name} --type=#{type} --private='#{value['private_key']}' --public='#{value['public_key']}'`
    else
      `credhub set --name=#{name} --type=#{type} --value='#{value}'`
    end
  end
end
