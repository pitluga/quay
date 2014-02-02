require 'spec_helper'

describe Quay::State do
  around(:each) do |spec|
    tmpfile = Tempfile.new('quay')
    @file  = tmpfile.path
    tmpfile.delete
    spec.run
    tmpfile.delete
  end

  describe "containers" do
    it "is initially an empty hash" do
      state = Quay::State.new(@file)
      state.containers.should == {}
    end

    it "can save a container for later" do
      state = Quay::State.new(@file)
      state.save_container("foo", "bar")

      state = Quay::State.new(@file)
      state.containers.should == {"foo" => "bar"}
    end

    it "can remove a container" do
      state = Quay::State.new(@file)
      state.save_container("foo", "bar")
      state.containers.should == {"foo" => "bar"}
      state.remove_container("foo")

      state = Quay::State.new(@file)
      state.containers.should == {}
    end
  end

end
