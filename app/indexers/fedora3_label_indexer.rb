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
    version = find_current_version
    {}.tap do |solr_doc|
      solr_doc['obj_label_tesim'] = resource.label || 'No label provided'
      solr_doc['has_model_ssim'] = resource.models.reject { |model| model == 'info:fedora/fedora-system:FedoraObject-3.0' }
      solr_doc['modified_latest_dttsi'] = resource.lastModifiedDate.to_datetime.utc.strftime('%FT%TZ')
      solr_doc[:id] = resource.pid
      solr_doc['current_version_isi'] = version # Argo Facet field "Version"
    end.merge(WorkflowFields.for(druid: resource.pid, version: version))
  end

  def find_current_version
    response = resource.datastreams['versionMetadata'].content
    return unless response # Handle atypical objects like EEMS permission files with no versionMetadata datastream

    ng_xml = Nokogiri::XML(response.body)
    ng_xml.xpath('//versionMetadata/version').map { |node| node['versionId'].to_i }.max
  end
end
