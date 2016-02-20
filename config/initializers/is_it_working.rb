require 'is_it_working'

unless Rails.env == 'test'
  Rails.configuration.middleware.use(IsItWorking::Handler) do |h|
    h.check :rubydora, :client => ActiveFedora::Base.connection_for_pid(0)
    h.check :rsolr, :client => Dor::SearchService.solr
  end
end
