require 'spec_helper'

describe "quay deps", type: :cli do
  before(:each) do
    quay("deps stop --config #{EXAMPLE_FILE}")
  end

  after(:each) do
    quay("deps stop --config #{EXAMPLE_FILE}")
  end

  describe "start" do
    it "starts the given dependency" do
      quay("deps start redis --config #{EXAMPLE_FILE}").should match(/Started redis/)
    end

    it "starts all dependencies" do
      output = quay("deps start --config #{EXAMPLE_FILE}")
      output.should match(/Started redis/)
      output.should match(/Started memcache/)
    end
  end

  describe "stop" do
    it "stop the given dependency" do
      quay("deps start redis --config #{EXAMPLE_FILE}").should match(/Started redis/)
      quay("deps stop redis --config #{EXAMPLE_FILE}").should match(/Stopped redis/)
    end

    it "stops all dependencies" do
      output = quay("deps start --config #{EXAMPLE_FILE}")
      output.should match(/Started redis/)
      output.should match(/Started memcache/)

      output = quay("deps stop --config #{EXAMPLE_FILE}")
      output.should match(/Stopped redis/)
      output.should match(/Stopped memcache/)
    end

    it "skips dependencies that are not running" do
      quay("deps stop redis --config #{EXAMPLE_FILE}").should match(/Skipping redis/)
    end
  end

  describe "list" do
    it "show the status of all dependencies" do
      output = quay("deps list --config #{EXAMPLE_FILE}")
      output.should match(/DEPENDENCY CONTAINER_ID/)
      output.should match(/^memcache *$/)
      output.should match(/^redis *$/)
    end

    it "shows the container id of a running container" do
      quay("deps start redis --config #{EXAMPLE_FILE}").should match(/Started redis/)

      output = quay("deps list --config #{EXAMPLE_FILE}")
      output.should match(/DEPENDENCY CONTAINER_ID/)
      output.should match(/^redis [a-z0-9]{12}*$/)
      output.should match(/^memcache *$/)
    end
  end
end
