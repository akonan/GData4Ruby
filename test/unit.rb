#!/usr/bin/ruby

require 'rubygems'
require 'gdata4ruby'
include GData4Ruby

@service = Service.new
@username = nil
@password = nil
@google_token = nil
@google_secret = nil

def tester
  if ARGV.include?("-d")
      @service.debug = true
  end
  ARGV.each do |ar|
    if ar.match("username=")
      @username = ar.gsub("username=", "")
    end
    if ar.match("password=")
      @password = ar.gsub("password=", "")
    end
    if ar.match("google_token=")
      @google_token = ar.gsub("google_token=", "")
    end
    if ar.match("google_secret=")
      @google_secret = ar.gsub("google_secret=", "")
    end

  end
  service_test
end

def service_test
  puts "---Starting Service Test---"
  puts "1. Authenticate"
  if @service.authenticate({:username => @username, :password => @password, :service => 'cl'})
    successful
  else
    failed
  end
  
  puts "2. Authenticate with GData version 3.0"
  @service = Service.new({:gdata_version => '3.0'})
  if @service.authenticate({:username => @username, :password => @password, :service => 'cl'}) and @service.gdata_version == '3.0'
    successful
  else
    failed
  end
  
  puts "3. Authenticate using OAuth"
  
  require 'oauth'
  consumer = OAuth::Consumer.new(@google_token, @google_secret, {
    :site => "https://www.google.com",
    :request_token_path => "/accounts/OAuthGetRequestToken",
    :access_token_path => "/accounts/OAuthGetAccessToken",
    :authorize_path=> "/accounts/OAuthAuthorizeToken"
  })
  access_token = OAuth::AccessToken.new(consumer, @google_token, @google_secret)
  @service = OAuthService.new
  if @service.authenticate({ :access_token => access_token })
    successful
  else
    failed
  end
end

def failed(m = nil)
  puts "Test Failed"
  puts m if m
  exit()
end

def successful(m = nil)
  puts "Test Successful"
  puts m if m
end

tester