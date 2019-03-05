#!/usr/bin/env ruby

require 'openssl'
require 'base64'

require_relative("lib/credhub.rb")

include Base64

output_dir = ENV["OUTPUT_DIR"]

if output_dir.nil?
    if Dir.exist?("out")
        output_dir = "out"
    else
        puts "OUTPUT_DIR not specified and `out` does not exist"
        exit 1
    end
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

set_credentials(decrypted_plain_text)
