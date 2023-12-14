# frozen_string_literal: true

require 'okcomputer'

OkComputer.mount_at = 'status' # use /status or /status/all or /status/<name-of-check>
OkComputer.check_in_parallel = true
OkComputer::Registry.deregister 'database' # we don't have a database

##
# REQUIRED checks

# Simple echo of the VERSION file
class VersionCheck < OkComputer::AppVersionCheck
  def version
    Rails.root.join('VERSION').read.chomp
  rescue Errno::ENOENT
    raise UnknownRevision
  end
end
OkComputer::Registry.register 'version', VersionCheck.new

##
# EXTERNAL Services

OkComputer::Registry.register 'external-solr', OkComputer::HttpCheck.new("#{Settings.solrizer_url.gsub(%r{/$}, '')}/admin/ping")

class RabbitQueueExistsCheck < OkComputer::Check
  attr_reader :queue_names, :conn

  def initialize(queue_names)
    @queue_names = Array(queue_names)
    @conn = Bunny.new(hostname: Settings.rabbitmq.hostname,
                      vhost: Settings.rabbitmq.vhost,
                      username: Settings.rabbitmq.username,
                      password: Settings.rabbitmq.password)
    super()
  end

  def check
    conn.start
    status = conn.status
    missing_queue_names = queue_names.reject { |queue_name| conn.queue_exists?(queue_name) }
    if missing_queue_names.empty?
      mark_message "'#{queue_names.join(', ')}' exists, connection status: #{status}"
    else
      mark_message "'#{missing_queue_names.join(', ')}' does not exist"
      mark_failure
    end
    conn.close
  rescue StandardError => e
    mark_message "Error: '#{e}'"
    mark_failure
  end
end

OkComputer::Registry.register 'rabbit-queue', RabbitQueueExistsCheck.new(['dor.indexing-by-druid', 'dor.indexing-with-model', 'dor.deleting-by-druid'])
