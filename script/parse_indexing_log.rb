#!/usr/bin/env ruby
#
# parses an `indexer.log` and outputs a CSV file of the timings.
#
# The data output are the real time as `:real` and percentage of time
# spend idle as `:pct_idle` (e.g., waiting for network requests), for
# the time it takes to read the core data from Fedora into an object
# `load:` and the time it takes to convert that object into a solr
# document `:to_solr`
#
# Usage: script/parse_indexing_log.rb [log/indexing.log ...] > data.csv
#
puts %w(druid load:real load:pct_idle to_solr:real to_solr:pct_idle total:real).join(',')

ARGF.lines do |line|
  matches = %r{successfully updated index for druid:([a-z0-9]+).+metrics: load_instance realtime ([\d\.]+)s total CPU ([\d\.]+)s; to_solr realtime ([\d\.]+)s total CPU ([\d\.]+)s}.match(line)
  if matches
    druid, load_real, load_cpu, solr_real, solr_cpu = matches[1..5]
    record = [
      druid,
      load_real,
      "%0.3f" % (100 * (load_real.to_f - load_cpu.to_f)/(load_real.to_f)),
      solr_real,
      "%0.3f" % (100 * (solr_real.to_f - solr_cpu.to_f)/(solr_real.to_f)),
      "%0.6f" % (load_real.to_f + solr_real.to_f)
    ]
    puts record.join(',')
  end
end
