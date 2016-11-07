# Load the Rails application.
require_relative 'application'

# load the dor-services config
require File.join(Rails.root, 'config', 'dor_config')

# Initialize the Rails application.
Rails.application.initialize!
