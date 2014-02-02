require 'spec_helper'

describe "quay", type: :cli do
  describe "version" do
    it "prints the version and exits" do
      quay("version").should match(/Quay Version [\d\.]+/)
    end
  end
end
