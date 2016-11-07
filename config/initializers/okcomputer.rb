require 'okcomputer'

OkComputer.mount_at = 'status' # use /status or /status/all or /status/<name-of-check>
OkComputer.check_in_parallel = true
OkComputer::Registry.deregister 'database' # we don't have a database

##
# REQUIRED checks

# Simple echo of the VERSION file
class VersionCheck < OkComputer::AppVersionCheck
  def version
    File.read(Rails.root.join('VERSION')).chomp
  rescue Errno::ENOENT
    raise UnknownRevision
  end
end
OkComputer::Registry.register 'version', VersionCheck.new

##
# EXTERNAL Services

OkComputer::Registry.register 'external-solr', OkComputer::SolrCheck.new(Dor::SearchService.solr.uri.to_s.gsub(/\/$/, ''))

# Simple check to ping the Fedora server by asking it to describe the repository
class FedoraCheck < OkComputer::Check
  def check
    conn = ActiveFedora::Base.connection_for_pid(0)
    profile = conn.repository_profile # use vs. `profile` to force a GET call to the server for `/fedora/describe`
    mark_message "Connected to #{profile['repositoryName']} #{profile['repositoryVersion']} via Rubydora #{Rubydora::VERSION}"
  rescue => e
    mark_failure
    mark_message "Failure: #{e.class.name}: #{e.message}"
  end
end

OkComputer::Registry.register 'external-fedora', FedoraCheck.new

OkComputer::Registry.register 'external-queue-size', (OkComputer::SizeThresholdCheck.new('Total queue size', 50000) do
  QueueStatus.all.queue_size
end)
