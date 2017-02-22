#!/usr/bin/env rspec

require_relative "../../spec_helper"
require "cm/configurators/base"
require "cm/configurations/salt"

describe Yast::CM::Configurators::Base do
  subject(:configurator) { Yast::CM::Configurators::Base.new(config) }

  let(:master) { "myserver" }
  let(:mode) { :client }
  let(:keys_url) { nil }
  let(:definitions_url) { "https://yast.example.net/myconfig.tgz" }
  let(:definitions_root) { FIXTURES_PATH.join("tmp") }
  let(:file_from_url_wrapper) { Yast::CM::FileFromUrlWrapper }

  let(:config) do
    Yast::CM::Configurations::Salt.new(
      auth_attempts: 3,
      auth_time_out: 10,
      master:        master,
      work_dir:      definitions_root,
      states_url:    definitions_url,
      keys_url:      keys_url
    )
  end

  class DummyClass < Yast::CM::Configurators::Base
    mode(:client) { 1 }
  end

  describe ".mode" do
    it "defines a method 'prepare_MODE'" do
      configurator = DummyClass.new({})
      expect(configurator.prepare_client).to eq(1)
    end
  end

  describe "#packages" do
    it "returns no packages to install/remove" do
      expect(configurator.packages).to eq({})
    end
  end

  describe "#prepare" do
    it "calls to 'prepare_MODE' method" do
      expect(configurator).to receive(:send).with("prepare_client")
      configurator.prepare
    end
  end

  describe "#fetch_keys" do
    let(:url) { URI("https://yast.example.net/keys") }
    let(:key_finder) { double("key_finder") }
    let(:public_key_path) { Pathname("/tmp/public") }
    let(:private_key_path) { Pathname("/tmp/private") }

    it "retrieves the authentication keys" do
      expect(Yast::CM::KeyFinder).to receive(:new)
        .with(keys_url: url).and_return(key_finder)
      expect(key_finder).to receive(:fetch_to)
        .with(private_key_path, public_key_path)
      configurator.fetch_keys(url, private_key_path, public_key_path)
    end
  end

  describe "#fetch_config" do
    let(:url) { "http://yast.example.net/config.tgz" }
    let(:target) { FIXTURES_PATH.join("tmp") }

    it "downloads and uncompress the configuration to a temporal directory" do
      expect(file_from_url_wrapper).to receive(:get_file)
        .with(url, target.join(Yast::CM::Configurators::Base::CONFIG_LOCAL_FILENAME))
        .and_return(true)
      expect(Yast::Execute).to receive(:locally).with("tar", "xf", *any_args)
        .and_return(true)

      configurator.fetch_config(url, target)
    end

    context "when the file is downloaded and uncompressed" do
      before do
        allow(file_from_url_wrapper).to receive(:get_file).and_return(true)
        allow(Yast::Execute).to receive(:locally).with("tar", *any_args).and_return(true)
      end

      it "returns true" do
        expect(configurator.fetch_config(url, target)).to eq(true)
      end
    end

    context "when download fails" do
      before do
        allow(file_from_url_wrapper).to receive(:get_file).and_return(false)
      end

      it "returns false" do
        expect(configurator.fetch_config(url, target)).to eq(false)
      end
    end

    context "when uncompressing fails" do
      before do
        allow(file_from_url_wrapper).to receive(:get_file).and_return(true)
        allow(Yast::Execute).to receive(:locally).with("tar", *any_args).and_return(false)
      end

      it "returns false" do
        expect(configurator.fetch_config(url, target)).to eq(false)
      end
    end
  end
end