require 'spec_helper'
require 'rails/generators'
require_relative '../../../../lib/generators/innsights/install/install_generator.rb'

describe Innsights::InstallGenerator do
  let(:generator) { Innsights::InstallGenerator.new}

  describe '.generate_config' do
    before do 
      generator.stub!(:template)
      generator.stub!(:processed_app_name)
    end

    it 'Creates a new client' do
      generator.stub!(:abort)
      Innsights::Client.should_receive(:create){nil}
      generator.generate_config 
    end
    it 'Exits with the correct message when there is no client' do
      Innsights::Client.stub!(:create){nil}
      generator.stub!(:abort)
      generator.should_receive(:abort)
      generator.generate_config 
    end
    it 'Adds the template when there is a client' do
      Innsights::Client.stub!(:create){Object.new}
      generator.should_receive(:template).with('innsights.yml', 'config/innsights.yml')
      generator.generate_config 
    end

    it 'Does not exit when there is a client' do
      Innsights::Client.stub!(:create){Object.new}
      generator.should_not_receive(:abort)
      generator.generate_config 
    end
  end

end
