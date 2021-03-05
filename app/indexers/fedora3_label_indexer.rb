# frozen_string_literal: true

# indexes the very basics of what we need so that we can find and fix these records
# prior to migrating away from Fedora 3
class Fedora3LabelIndexer
  attr_reader :resource

  def initialize(resource:, **)
    @resource = resource
  end

  # @return [Hash] the partial solr document
  def to_solr
    Rails.logger.debug "In #{self.class}"

    {}.tap do |solr_doc|
      solr_doc['obj_label_tesim'] = resource.label
      solr_doc['modified_latest_dttsi'] = resource.modified_date.to_datetime.utc.strftime('%FT%TZ')
      solr_doc[SOLR_DOCUMENT_ID.to_sym] = resource.pid
    end
  end
end
