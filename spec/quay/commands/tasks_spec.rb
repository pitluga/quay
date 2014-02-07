require 'spec_helper'

describe 'quay tasks', type: :cli do
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
  end
end
