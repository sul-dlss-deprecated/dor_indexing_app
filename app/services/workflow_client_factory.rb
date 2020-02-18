# frozen_string_literal: true

# This initializes the workflow client with values from settings
class WorkflowClientFactory
  def self.build
    logger = Logger.new(Settings.WORKFLOW.LOGFILE, Settings.WORKFLOW.SHIFT_AGE)
    Dor::Workflow::Client.new(url: Settings.WORKFLOW_URL, logger: logger, timeout: Settings.WORKFLOW.TIMEOUT)
  end
end
