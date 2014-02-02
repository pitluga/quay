$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require 'quay'
require 'support/cli_driver'

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = 'random'

  config.include CLIDriver, type: :cli
end

EXAMPLE_FILE = File.expand_path('../Quayfile', __FILE__)
