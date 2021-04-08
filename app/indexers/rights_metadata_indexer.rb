# frozen_string_literal: true

class RightsMetadataIndexer
  attr_reader :resource, :cocina

  def initialize(resource:, cocina:, **)
    @resource = resource
    @cocina = cocina
  end

  # @return [Hash] the partial solr document for rightsMetadata
  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/PerceivedComplexity
  def to_solr
    Rails.logger.debug "In #{self.class}"

    solr_doc = {
      'copyright_ssim' => resource.rightsMetadata.copyright,
      'use_statement_ssim' => resource.rightsMetadata.use_statement
    }

    dra = resource.rightsMetadata.dra_object

    solr_doc['rights_descriptions_ssim'] = [
      dra.index_elements[:primary],

      (dra.index_elements[:obj_locations_qualified] || []).map do |rights_info|
        rule_suffix = rights_info[:rule] ? " (#{rights_info[:rule]})" : ''
        "location: #{rights_info[:location]}#{rule_suffix}"
      end,
      (dra.index_elements[:file_locations_qualified] || []).map do |rights_info|
        rule_suffix = rights_info[:rule] ? " (#{rights_info[:rule]})" : ''
        "location: #{rights_info[:location]} (file)#{rule_suffix}"
      end,

      (dra.index_elements[:obj_groups_qualified] || []).map do |rights_info|
        rule_suffix = rights_info[:rule] ? " (#{rights_info[:rule]})" : ''
        "#{rights_info[:group]}#{rule_suffix}"
      end,
      (dra.index_elements[:file_groups_qualified] || []).map do |rights_info|
        rule_suffix = rights_info[:rule] ? " (#{rights_info[:rule]})" : ''
        "#{rights_info[:group]} (file)#{rule_suffix}"
      end,

      (dra.index_elements[:obj_world_qualified] || []).map do |rights_info|
        rule_suffix = rights_info[:rule] ? " (#{rights_info[:rule]})" : ''
        "world#{rule_suffix}"
      end,
      (dra.index_elements[:file_world_qualified] || []).map do |rights_info|
        rule_suffix = rights_info[:rule] ? " (#{rights_info[:rule]})" : ''
        "world (file)#{rule_suffix}"
      end
    ].flatten.uniq

    # these two values are returned by index_elements[:primary], but are just a less granular version of
    # what the other more specific fields return, so discard them
    solr_doc['rights_descriptions_ssim'] -= %w[access_restricted access_restricted_qualified world_qualified]
    solr_doc['rights_descriptions_ssim'] += ['dark (file)'] if dra.index_elements[:terms].include? 'none_read_file'
    if dra.index_elements[:primary].include? 'cdl_none'
      solr_doc['rights_descriptions_ssim'] += ['controlled digital lending']
      solr_doc['rights_descriptions_ssim'] -= ['cdl_none']
    end

    # suppress empties
    %w[use_statement_ssim copyright_ssim].each do |key|
      solr_doc[key] = solr_doc[key].reject(&:blank?).flatten unless solr_doc[key].nil?
    end

    solr_doc['use_license_machine_ssi'] = license

    solr_doc
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/PerceivedComplexity

  private

  LICENSE_CODE = {
    'http://cocina.sul.stanford.edu/licenses/none' => 'none', # Only used in some legacy ETDs.
    'https://creativecommons.org/licenses/by/3.0/' => 'by',
    'https://creativecommons.org/licenses/by-sa/3.0/' => 'by-sa',
    'https://creativecommons.org/licenses/by-nd/3.0/' => 'by-nd',
    'https://creativecommons.org/licenses/by-nc/3.0/' => 'by-nc',
    'https://creativecommons.org/licenses/by-nc-sa/3.0/' => 'by-nc-sa',
    'https://creativecommons.org/licenses/by-nc-nd/3.0/' => 'by-nc-nd',
    'https://creativecommons.org/licenses/by/4.0/' => 'CC-BY-4.0',
    'https://creativecommons.org/licenses/by-sa/4.0/' => 'CC-BY-SA-4.0',
    'https://creativecommons.org/licenses/by-nd/4.0/' => 'CC-BY-ND-4.0',
    'https://creativecommons.org/licenses/by-nc/4.0/' => 'CC-BY-NC-4.0',
    'https://creativecommons.org/licenses/by-nc-sa/4.0/' => 'CC-BY-NC-SA-4.0',
    'https://creativecommons.org/licenses/by-nc-nd/4.0/' => 'CC-BY-NC-ND-4.0',
    'https://creativecommons.org/publicdomain/mark/1.0/' => 'pdm',
    'https://creativecommons.org/publicdomain/zero/1.0/' => 'CC0-1.0',
    'http://opendatacommons.org/licenses/pddl/1.0/' => 'pddl',
    'http://opendatacommons.org/licenses/by/1.0/' => 'odc-by',
    'http://opendatacommons.org/licenses/odbl/1.0/' => 'odc-odbl'
  }.freeze

  # @return [String] the code if we've defined one, or the URI if we haven't.
  def license
    return if cocina.admin_policy?

    uri = cocina.access.license
    LICENSE_CODE.fetch(uri, uri)
  end
end
