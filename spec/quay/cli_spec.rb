require 'spec_helper'

describe Quay::CLI, type: :cli do
  describe "default config" do
    it "looks in the working directory" do
      Dir.chdir(File.dirname(EXAMPLE_FILE)) do
        output = quay('services')
        output.should match(/DEPENDENCY CONTAINER_ID/)
        output.should match(/^memcache *$/)
        output.should match(/^redis *$/)
      end
    end
  end

  describe "version" do
    it "prints the version and exits" do
      quay("version").should match(/Quay Version [\d\.]+/)
    end
  end

  describe "init" do
    it "generates a Quayfile in the current dir" do
      Dir.mktmpdir do |dir|
        Dir.chdir(dir) do
          File.exist?("Quayfile").should == false
          quay("init")
          File.exist?("Quayfile").should == true
        end
      end
    end

    it "generates a Quayfile in the given dir" do
      Dir.mktmpdir do |dir|
        File.exist?(File.join(dir, "Quayfile")).should == false
        quay("init #{dir}")
        File.exist?(File.join(dir, "Quayfile")).should == true
      end
    end
  end

  describe "services" do
    before(:each) do
      quay("stop redis --config #{EXAMPLE_FILE}")
      quay("stop memcache --config #{EXAMPLE_FILE}")
    end

    after(:each) do
      quay("stop redis --config #{EXAMPLE_FILE}")
      quay("stop memcache --config #{EXAMPLE_FILE}")
    end

    describe "start" do
      it "starts the given dependency" do
        quay("start redis --config #{EXAMPLE_FILE}").should match(/Started redis/)
      end

      it "returns an error if the name is unknown" do
        quay("start unknown --config #{EXAMPLE_FILE}").should match(/unknown service "unknown"/)
        $?.exitstatus.should == 1
      end
    end

    describe "stop" do
      it "stop the given dependency" do
        quay("start redis --config #{EXAMPLE_FILE}").should match(/Started redis/)
        quay("stop redis --config #{EXAMPLE_FILE}").should match(/Stopped redis/)
      end

      it "skips dependencies that are not running" do
        quay("stop redis --config #{EXAMPLE_FILE}").should match(/Skipping redis/)
      end

      it "returns an error if the name is unknown" do
        quay("stop unknown --config #{EXAMPLE_FILE}").should match(/unknown service "unknown"/)
        $?.exitstatus.should == 1
      end
    end

    describe "list" do
      it "show the status of all dependencies" do
        output = quay("services --config #{EXAMPLE_FILE}")
        output.should match(/DEPENDENCY CONTAINER_ID/)
        output.should match(/^memcache *$/)
        output.should match(/^redis *$/)
      end

      it "shows the container id of a running container" do
        quay("start redis --config #{EXAMPLE_FILE}").should match(/Started redis/)

        output = quay("services --config #{EXAMPLE_FILE}")
        output.should match(/DEPENDENCY CONTAINER_ID/)
        output.should match(/^redis [a-z0-9]{12}*$/)
        output.should match(/^memcache *$/)
      end
    end
  end

  describe 'list' do
    it "lists the available tasks" do
      output = quay("tasks --config #{EXAMPLE_FILE}")
      output.should match(/sayhi/)
    end
  end

  describe 'run' do
    it "runs the specified task" do
      output = quay("run sayhi --config #{EXAMPLE_FILE}")
      output.should match(/hello world/)
    end

    it "can run a task with a dependency" do
      output = quay("run redis_info --config #{EXAMPLE_FILE}")
      output.should match(/used_memory/)
    end

    it "returns an error if the name is unknown" do
      quay("run unknown --config #{EXAMPLE_FILE}").should match(/unknown task "unknown"/)
      $?.exitstatus.should == 1
    end

    it "can mount a volume" do
      quay("run ls_volume --config #{EXAMPLE_FILE}").should match(/quay.gemspec/)
    end

    it "will pull an image that doesn't exist" do
      images = Docker::Image.search('ubuntu')
      images.each(&:remove)
      quay("run sayhi --config #{EXAMPLE_FILE}").should match(/hello world/)
    end

    it "will exit with the exit code of the task" do
      quay("run failure --config #{EXAMPLE_FILE}")
      $?.exitstatus.should == 1
    end
  end
end
