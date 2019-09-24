# frozen_string_literal: true

# Load the Rails application.
require_relative 'application'

# load the dor-services config
require Rails.root.join('config', 'dor_config')

# Initialize the Rails application.
Rails.application.initialize!
