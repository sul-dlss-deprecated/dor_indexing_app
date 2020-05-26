# frozen_string_literal: true

class ObjectProfileIndexer
  include SolrDocHelper

  attr_reader :resource

  def initialize(resource:)
    @resource = resource
  end

  # @return [Hash] the partial solr document for releasable concerns
  def to_solr
    return {} unless inner_object.respond_to?(:profile) # Skip unsaved items

    {}.tap do |solr_doc|
      inner_object.profile.each_pair do |property, value|
        add_solr_value(solr_doc, property.underscore, value, (property.match?(/Date/) ? :date : :symbol), [:stored_searchable])
      end
    end
  end

  # rubocop:disable Lint/UselessAccessModifier
  private

  # rubocop:enable Lint/UselessAccessModifier

  delegate :inner_object, to: :resource
end
