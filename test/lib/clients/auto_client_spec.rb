#!/usr/bin/env rspec

require_relative "../../spec_helper"
require "configuration_management/clients/auto_client"
require "configuration_management/configurators/salt"

describe Yast::ConfigurationManagement::AutoClient do
  subject(:client) { described_class.new }

  let(:configurator) { double("configurator", packages: packages) }
  let(:packages) { { "install" => ["pkg1"] } }
  let(:profile) { { "type" => "salt", "master" => "myserver" } }
  let(:config) { Yast::ConfigurationManagement::Configurations::Base.for(profile) }

  before do
    allow(Yast::ConfigurationManagement::Configurations::Base).to receive(:for).with(profile)
      .and_return(config)
  end

  describe "#import" do
    it "initializes the current configurator" do
      expect(Yast::ConfigurationManagement::Configurators::Base).to receive(:for)
        .with(config).and_call_original
      client.import(profile)
      expect(Yast::ConfigurationManagement::Configurators::Base.current)
        .to be_kind_of(Yast::ConfigurationManagement::Configurators::Salt)
    end
  end

  describe "#packages" do
    before do
      expect(Yast::ConfigurationManagement::Configurators::Base).to receive(:for)
        .with(config).and_return(configurator)
      client.import(profile)
    end

    it "returns provider list of packages" do
      expect(client.packages).to eq(packages)
    end
  end

  describe "#export" do
    it "returns an empty hash" do
      expect(client.export).to eq({})
    end
  end

  describe "#modified" do
    it "returns false" do
      expect(client.modified).to eq(false)
    end
  end

  describe "#modified?" do
    it "returns false" do
      expect(client.modified).to eq(false)
    end
  end
end
