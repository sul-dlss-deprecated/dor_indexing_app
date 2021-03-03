# frozen_string_literal: true

class DefaultObjectRightsDatastreamIndexer
  attr_reader :cocina

  def initialize(cocina:, **)
    @cocina = cocina
  end

  # @return [Hash] the partial solr document for defaultObjectRights
  def to_solr
    {
      'use_statement_ssim' => use_statement,
      'copyright_ssim' => copyright
    }
  end

  private

  def xml
    @xml ||= cocina.administrative.defaultObjectRights
  end

  def ng_xml
    @ng_xml ||= Nokogiri::XML(xml) if xml
  end

  def use_statement
    ng_xml.xpath('//rightsMetadata/use/human[@type="useAndReproduction"]').map(&:text)
  end

  def copyright
    ng_xml.xpath('//rightsMetadata/copyright/human').map(&:text)
  end
end
