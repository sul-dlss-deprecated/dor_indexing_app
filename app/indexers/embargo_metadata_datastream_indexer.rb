# frozen_string_literal: true

class EmbargoMetadataDatastreamIndexer
  attr_reader :resource

  def initialize(resource:, **)
    @resource = resource
  end

  # These fields are used by the EmbargoReleaseService in dor-services-app
  # @return [Hash] the partial solr document for embargoMetadata
  def to_solr
    {
      'embargo_status_ssim' => embargo_status
    }.tap do |solr_doc|
      solr_doc['embargo_release_dtsim'] = Array(release_date.first.utc.strftime('%FT%TZ')) if release_date.first.present?
    end
  end

  # rubocop:disable Lint/UselessAccessModifier
  private

  # rubocop:enable Lint/UselessAccessModifier

  delegate :embargoMetadata, to: :resource
  delegate :embargo_status, :release_date, to: :embargoMetadata
end
