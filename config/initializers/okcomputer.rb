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
    File.read(Rails.root.join('VERSION')).chomp
  rescue Errno::ENOENT
    raise UnknownRevision
  end
end
OkComputer::Registry.register 'version', VersionCheck.new

##
# EXTERNAL Services

OkComputer::Registry.register 'external-solr', OkComputer::HttpCheck.new("#{Settings.solrizer_url.gsub(%r{/$}, '')}/admin/ping")
