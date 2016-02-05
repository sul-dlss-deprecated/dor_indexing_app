# Load the Rails application.
require File.expand_path('../application', __FILE__)

# load the dor-services config
require File.join(Rails.root, 'config', 'dor_config')

# Initialize the Rails application.
Rails.application.initialize!
