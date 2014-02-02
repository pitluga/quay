require 'spec_helper'

describe Quay::Config do
  describe ".evaluate" do
    context "dep" do
      it "adds a dependency" do
        config = Quay::Config.evaluate <<-EOS
          dep "foo", image: "bar"
        EOS

        config.deps.has_key?("foo").should be_true
        config.deps["foo"].should == { image: "bar" }
      end
    end
  end
end
