# frozen_string_literal: true

class RightsMetadataIndexer
  attr_reader :resource, :cocina

  def initialize(resource:, cocina:, **)
    @resource = resource
    @cocina = cocina
  end

  def cocina_to_solr
    {}.tap do |fields|
      fields['copyright_ssim'] = cocina.access.copyright
      fields['use_statement_ssim'] = cocina.access.useAndReproductionStatement
      fields['use_license_machine_ssi'] = cocina.access.license
      fields['rights_descriptions_ssim'] = rights_descriptions
    end.compact
  end

  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/PerceivedComplexity
  def rights_descriptions
    results = []
    root = case cocina.access.access
           when 'dark'
             'dark'
           when 'citation-only'
             'citation'
           when 'location-based'
             # FIXME: what if readLocation isn't present?
             "location: #{cocina.access.readLocation}" if cocina.access.readLocation.present?
           when 'stanford'
             'stanford'
           when 'world'
             'world'
           end

    case cocina.access.download
    when 'none'
      if ['dark', 'citation'].include?(root)
        results.push(root)
      else
        results.push("#{root} (no-download)")
      end
    when 'world'
      results.push(root)
    when 'stanford'
      results.push(root) if root == 'stanford'
    when 'location-based'
      results.push(root) if root&.start_with?('location')
    when nil
      results.push(root)
    end

    results.push('controlled digital lending') if cocina.access.controlledDigitalLending.present?
    results
  end
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/PerceivedComplexity

  # @return [Hash] the partial solr document for rightsMetadata
  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/PerceivedComplexity
  def fedora_to_solr
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

    solr_doc['use_license_machine_ssi'] = resource.rightsMetadata.use_license.first

    solr_doc
  end
  alias to_solr fedora_to_solr
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/PerceivedComplexity
end
