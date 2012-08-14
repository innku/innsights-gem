ENV["RAILS_ENV"] ||= 'test'

require File.expand_path("../dummy/config/environment", __FILE__)
require 'rubygems'
require 'rails'
require 'rspec/rails'
require 'rspec/autorun'
require 'bundler/setup'
require 'vcr'
require 'innsights'

require File.join(File.dirname(__FILE__), 'support', 'ar')

VCR.config do |c|
  c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  c.stub_with :webmock # or :fakeweb
end

RSpec.configure do |config|
  config.before(:all) do
    Innsights.mode :test
  end
end

Innsights.setup do
  config :development do
    queue :resque
    test  true
  end
end

def json_fixture(filename)
  File.open(File.join(File.dirname(__FILE__), 'fixtures/json', filename))
end

