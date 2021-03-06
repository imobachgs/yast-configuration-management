#!/usr/bin/env rspec

require_relative "../../spec_helper"
require "configuration_management/runners/salt"
require "configuration_management/configurations/salt"

describe Yast::ConfigurationManagement::Runners::Salt do
  subject(:runner) { Yast::ConfigurationManagement::Runners::Salt.new(config) }
  let(:master) { "salt.suse.de" }
  let(:tmpdir) { "/mnt/tmp/yast_cm" }

  let(:config) do
    Yast::ConfigurationManagement::Configurations::Salt.new(master: master)
  end

  before do
    allow(Dir).to receive(:mktmpdir).and_return(tmpdir)
  end

  describe "#run" do
    before do
      allow(runner).to receive(:sleep)
      allow(Yast::Installation).to receive(:destdir).and_return("/mnt")
    end

    context "when running in client mode" do
      it "runs salt-call" do
        expect(Cheetah).to receive(:run).with(
          "salt-call", "--log-level", "debug", "state.highstate",
          stdout: $stdout, stderr: $stderr, chroot: "/mnt"
        )
        expect(runner.run).to eq(true)
      end

      context "when salt-call fails" do
        it "returns false" do
          expect(Cheetah).to receive(:run)
            .with("salt-call", *any_args)
            .and_raise(Cheetah::ExecutionFailed.new([], 0, nil, nil))
            .exactly(config.auth_attempts).times
          expect(runner.run).to eq(false)
        end
      end
    end

    context "when running in masterless mode" do
      let(:master) { nil }

      it "runs salt-call" do
        expect(Cheetah).to receive(:run).with(
          "salt-call", "--log-level", "debug",
          "--local", "--pillar-root=#{config.pillar_root(:target)}",
          "state.highstate",
          stdout: $stdout, stderr: $stderr, chroot: "/mnt"
        )
        expect(runner.run).to eq(true)
      end
    end
  end
end
