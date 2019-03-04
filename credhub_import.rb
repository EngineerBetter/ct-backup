#!/usr/bin/env ruby

require 'openssl'
require 'base64'
require 'tempfile'
require 'securerandom'

include Base64

output_dir = ENV["OUTPUT_DIR"]

if output_dir.nil?
    `mkdir -p out`
    output_dir = "out"
end
encoded_key = ENV["ENCRYPTION_KEY"]

if encoded_key.nil?
    puts "ENCRYPTION KEY must be set"
    exit 1
end

decryption_key = urlsafe_decode64(encoded_key)

encrypted_creds = File.read("#{output_dir}/creds.encrypted")

cipher = OpenSSL::Cipher::AES128.new(:CBC)
cipher.decrypt
cipher.key = decryption_key
decrypted_plain_text = cipher.update(encrypted_creds) + cipher.final

file = Tempfile.new(SecureRandom.hex(16))
file.write(decrypted_plain_text)

`credhub import -f #{file.path}`

file.close
file.unlink
