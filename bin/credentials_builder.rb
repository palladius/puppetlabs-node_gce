#!/usr/bin/env ruby

require 'rubygems'
require 'oauth2'

redirect_uri = 'urn:ietf:wg:oauth:2.0:oob'
scope = "https://www.googleapis.com/auth/compute https://www.googleapis.com/auth/compute.readonly https://www.googleapis.com/auth/devstorage.full_control https://www.googleapis.com/auth/devstorage.read_only https://www.googleapis.com/auth/devstorage.read_write https://www.googleapis.com/auth/devstorage.write_only https://www.googleapis.com/auth/userinfo.email"


puts "Building credentials file for Google Compute Oauth2"

print "Enter client_id: "
client_id = STDIN.gets.chomp

print "Enter client_secret: "
client_secret = STDIN.gets.chomp
puts

client = OAuth2::Client.new(client_id, client_secret, :site => 'https://accounts.google.com', :token_url => '/o/oauth2/token', :authorize_url => '/o/oauth2/auth')
webpage = client.auth_code.authorize_url(:redirect_uri => redirect_uri, :scope => scope)

puts "Go to this link to authorize the application:\n\n#{webpage}\n\n"
print "and enter the code you find after authorizing: "
code = STDIN.gets.chomp

token = client.auth_code.get_token(code, :redirect_uri => redirect_uri)
refresh_token = token.refresh_token

puts "client_id: #{client_id}"
puts "client_secret: #{client_secret}"
puts "authorization_code: #{code}"
puts "refresh_token: #{refresh_token}"

puts
print "Enter file for storing OAuth2 credentials [/tmp/oauth2_credentials.rb]: "
filename = STDIN.gets.chomp.strip
filename = "/tmp/oauth2_credentials.rb" if filename == ''

puts "Storing credentials information in [#{filename}]..."

File.open(filename, 'w') do |f|
  f.puts ":gce:"
  f.puts %Q{  :client_id: "#{client_id}"}
  f.puts %Q{  :client_secret: "#{client_secret}"}
  f.puts %Q{  :authorization_code: "#{code}"}
  f.puts %Q{  :refresh_token: "#{refresh_token}"}
end
