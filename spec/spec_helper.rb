begin
  require 'spec'
rescue LoadError
  require 'rubygems'
  gem 'rspec'
  require 'spec'
end
require 'net/http'

$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'handle_http'
