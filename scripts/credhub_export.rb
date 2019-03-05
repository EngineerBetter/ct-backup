#!/usr/bin/env ruby

require 'openssl'
require "base64"

include Base64

output_dir = 'out'

credhub_contents = `credhub export`

# create the cipher for encrypting
cipher = OpenSSL::Cipher::AES128.new(:CBC)
cipher.encrypt
key = cipher.random_key
cipher_text = cipher.update(credhub_contents) + cipher.final

File.write("#{output_dir}/creds.encrypted", cipher_text)
puts "Key: " + urlsafe_encode64(key)
