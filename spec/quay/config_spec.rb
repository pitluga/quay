require 'spec_helper'

describe Quay::Config do
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
