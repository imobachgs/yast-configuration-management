#!/usr/bin/env rspec

require_relative "../../spec_helper"
require "y2configuration_management/configurations/salt"
require "tmpdir"

describe Y2ConfigurationManagement::Configurations::Salt do
  subject(:config) { Y2ConfigurationManagement::Configurations::Salt.new(profile) }

  let(:master) { "puppet.suse.de" }
  let(:states_url) { "http://ftp.suse.de/modules.tgz" }

  let(:profile) do
    {
      master:     master,
      states_url: URI(states_url)
    }
  end

  describe "#type" do
    it "returns 'salt'" do
      expect(config.type).to eq("salt")
    end
  end

  describe "#states_root" do
    it "returns work_dir + 'salt'" do
      expect(config.states_root).to eq(config.work_dir.join("salt"))
    end
  end

  describe "#pillar_root" do
    it "returns work_dir + 'pillar'" do
      expect(config.pillar_root).to eq(config.work_dir.join("pillar"))
    end
  end
end
