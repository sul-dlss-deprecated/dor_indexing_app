# frozen_string_literal: true

class ContentMetadataDatastreamIndexer
  attr_reader :resource, :cocina

  def initialize(resource:, cocina:, id:)
    @resource = resource
    @cocina = cocina
  end

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/PerceivedComplexity
  # @return [Hash] the partial solr document for contentMetadata
  def to_solr
    return {} unless doc.root['type']

    counts = Hash.new(0)                # default count is zero
    resource_type_counts = Hash.new(0)  # default count is zero

    file_sets = cocina.structural.contains
    counts['resource'] = file_sets.size
    files = file_sets.flat_map { |fs| fs.structural.contains }
    counts['content_file'] = files.size
    preserved_files = files.select { |file| file.administrative.sdrPreserve }
    preserved_size = preserved_files.sum(&:size)
    shelved_files = files.select { |file| file.administrative.shelve }
    counts['shelved_file'] = shelved_files.size
    mime_types = files.map(&:hasMimeType)
    file_roles = files.map(&:use).compact
    first_shelved_image = shelved_files.find { |file| file.filename.end_with?('jp2') }&.filename

    doc.xpath('contentMetadata/resource').each do |resource|
      resource_type_counts[resource['type']] += 1 if resource['type']
    end
    solr_doc = {
      'content_type_ssim' => doc.root['type'],
      'content_file_mimetypes_ssim' => mime_types.to_a,
      'content_file_count_itsi' => counts['content_file'],
      'shelved_content_file_count_itsi' => counts['shelved_file'],
      'resource_count_itsi' => counts['resource'],
      'preserved_size_dbtsi' => preserved_size # double (trie) to support very large sizes
    }
    solr_doc['resource_types_ssim'] = resource_type_counts.keys unless resource_type_counts.empty?
    solr_doc['content_file_roles_ssim'] = file_roles.to_a unless file_roles.empty?
    resource_type_counts.each do |key, count|
      solr_doc["#{key}_resource_count_itsi"] = count
    end
    # first_shelved_image is neither indexed nor multiple
    solr_doc['first_shelved_image_ss'] = first_shelved_image unless first_shelved_image.nil?
    solr_doc
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/PerceivedComplexity

  private

  def doc
    @doc ||= resource.contentMetadata.ng_xml
  end
end
