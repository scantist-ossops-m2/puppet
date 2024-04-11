#!/usr/bin/env rspec

shared_examples_for "a file_serving model" do
  include PuppetSpec::Files

  describe "#indirection" do
    before :each do
      # Never connect to the network, no matter what
      described_class.indirection.terminus(:rest).class.any_instance.stubs(:find)
    end

    describe "when running the master application" do
      before :each do
        Puppet::Application[:master].setup_terminuses
      end

      {
       "/etc/sudoers"                    => :file_server,
       "file:///etc/sudoers"             => :file_server,
       "puppet:///modules/foo/bar"       => :file_server,
       "puppet://server/modules/foo/bar" => :file_server,
      }.each do |key, terminus|
        it "should use the #{terminus} terminus when requesting #{key.inspect}" do
          described_class.indirection.terminus(terminus).class.any_instance.expects(:find)

          described_class.indirection.find(key)
        end
      end
    end

    describe "when running the apply application" do
      before :each do
        # Stub this so we can set the 'name' setting
        Puppet::Util::Settings::ReadOnly.stubs(:include?)
        Puppet[:name] = 'apply'
      end

      {
       "/etc/sudoers"                    => :file,
       "file:///etc/sudoers"             => :file,
       "puppet:///modules/foo/bar"       => :file_server,
       "puppet://server/modules/foo/bar" => :rest,
      }.each do |key, terminus|
        it "should use the #{terminus} terminus when requesting #{key.inspect}" do
          described_class.indirection.terminus(terminus).class.any_instance.expects(:find)

          described_class.indirection.find(key)
        end
      end
    end

    describe "when running another application" do
      before :each do
        # Stub this so we can set the 'name' setting
        Puppet::Util::Settings::ReadOnly.stubs(:include?)
        Puppet[:name] = 'agent'
      end

      {
       "/etc/sudoers"                    => :file,
       "file:///etc/sudoers"             => :file,
       "puppet:///modules/foo/bar"       => :rest,
       "puppet://server/modules/foo/bar" => :rest,
      }.each do |key, terminus|
        it "should use the #{terminus} terminus when requesting #{key.inspect}" do
          described_class.indirection.terminus(terminus).class.any_instance.expects(:find)

          described_class.indirection.find(key)
        end
      end
    end
  end
end
