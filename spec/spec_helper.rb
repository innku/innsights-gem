require 'rubygems'
require 'rspec'
require 'bundler/setup'
require 'active_record'
require 'active_support'
require 'vcr'
require 'innsights'

Innsights.log_errors = false

require File.join(File.dirname(__FILE__), 'support', 'ar')

VCR.config do |c|
  c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  c.stub_with :webmock # or :fakeweb
  c.ignore_localhost = true
end


RSpec.configure do |config|
  config.before(:each) do
    Innsights.mode :test
    Post.destroy_all
    User.destroy_all
    Company.destroy_all
  end
end

def json_fixture(filename)
  File.open(File.join(File.dirname(__FILE__), 'fixtures/json', filename))
end

