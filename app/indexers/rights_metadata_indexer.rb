# frozen_string_literal: true

class RightsMetadataIndexer
  attr_reader :cocina

  def initialize(cocina:, **)
    @cocina = cocina
  end

  # @return [Hash] the partial solr document for rightsMetadata
  def to_solr
    Rails.logger.debug "In #{self.class}"

    {
      'copyright_ssim' => cocina.access.copyright,
      'use_statement_ssim' => cocina.access.useAndReproductionStatement,
      'use_license_machine_ssi' => license,
      'rights_descriptions_ssim' => cocina.dro? ? rights_descriptions_for_item : rights_descriptions_for_collection
    }.compact
  end

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

  def rights_descriptions_for_collection
    build_basic_access(cocina.access)
  end

  def rights_descriptions_for_item
    return 'controlled digital lending' if cocina.access.controlledDigitalLending

    basic_access = build_basic_access_with_download(cocina.access)
    files = Array(cocina.structural.contains).flat_map { |fs| Array(fs.structural.contains) }
                                             .map { |file| build_basic_access_with_download(file.access) }.uniq

    [basic_access] + files.map { |result| "#{result} (file)" }
  end

  def build_basic_access(access)
    case access.access
    when 'citation-only'
      'citation'
    when 'dark'
      'dark'
    when 'location-based'
      "location: #{access.readLocation}"
    else
      access.access
    end
  end

  def build_basic_access_with_download(access)
    basic_access = build_basic_access(access)
    return basic_access if access.download != 'none' || %w[dark citation].include?(basic_access)

    "#{basic_access} (no-download)"
  end

  # @return [String] the code if we've defined one, or the URI if we haven't.
  def license
    uri = cocina.access.license
    LICENSE_CODE.fetch(uri, uri)
  end
end
