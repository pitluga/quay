require 'spec_helper'

describe Quay::Config do
  describe ".determine_path" do
    it "returns the custom path if provided" do
      Quay::Config.determine_path("/foo/bar").should == "/foo/bar"
    end

    it "returns Quayfile if custom path not provided" do
      Quay::Config.determine_path(nil).should == "Quayfile"
    end

    it "returns the value of the QUAYFILE environment variable" do
      with_env("QUAYFILE", "/foo/bar") do
        Quay::Config.determine_path(nil).should == "/foo/bar"
      end
    end

    it "custom path overrides the environment variable" do
      with_env("QUAYFILE", "/foo/bar") do
        Quay::Config.determine_path('/baz/qux').should == "/baz/qux"
      end
    end
  end

  describe ".evaluate" do
    context "service" do
      it "is an empty hash by default" do
        config = Quay::Config.evaluate("")
        config.services.should == {}
      end

      it "adds a dependency" do
        config = Quay::Config.evaluate <<-EOS
          service "foo", image: "bar"
        EOS

        config.services.has_key?("foo").should be_true
        config.services["foo"].should == { image: "bar" }
      end
    end

    context "task" do
      it "is an empty hash by default" do
        config = Quay::Config.evaluate("")
        config.tasks.should == {}
      end

      it "defines a task" do
        config = Quay::Config.evaluate <<-EOS
          task "sayhi", image: "bar"
        EOS

        config.tasks.has_key?("sayhi").should be_true
        config.tasks["sayhi"].should == { image: "bar" }
      end
    end
  end
end
