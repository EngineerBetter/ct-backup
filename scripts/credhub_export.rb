#!/usr/bin/env ruby

require 'openssl'
require "base64"

include Base64

output_dir = ENV["OUTPUT_DIR"]

if output_dir.nil?
    `mkdir -p out`
    output_dir = "out"
end

credhub_contents = `credhub export`

# create the cipher for encrypting
cipher = OpenSSL::Cipher::AES128.new(:CBC)
cipher.encrypt
key = cipher.random_key
cipher_text = cipher.update(credhub_contents) + cipher.final

File.write("#{output_dir}/creds.encrypted", cipher_text)
puts "Key: " + urlsafe_encode64(key)
