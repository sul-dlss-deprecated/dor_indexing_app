# frozen_string_literal: true

class RightsDescriptionBuilder
  def self.build(cocina)
    new(cocina).build
  end

  def initialize(cocina)
    @cocina = cocina
  end

  def build
    cocina.dro? ? rights_descriptions_for_item : rights_descriptions_for_collection
  end

  private

  attr_reader :cocina

  def rights_descriptions_for_collection
    case cocina.access.access
    when 'world'
      'world'
    else
      'citation'
    end
  end

  def rights_descriptions_for_item
    return 'controlled digital lending' if cocina.access.controlledDigitalLending

    return ['dark'] if cocina.access.access == 'dark'

    object_level_access + access_level_from_files.uniq.map { |str| "#{str} (file)" }
  end

  def access_level_from_files
    # dark access doesn't permit any file access
    return [] if cocina.access.access == 'dark'

    file_access_nodes.reject { |fa| same_as_object_access?(fa) }.flat_map do |fa|
      file_access_from_file(fa)
    end
  end

  def file_access_from_file(file_access)
    basic_access = if file_access[:access] == 'location-based'
                     "location: #{file_access[:readLocation]}"
                   else
                     file_access[:access]
                   end

    return [basic_access] if file_access[:access] == file_access[:download]

    basic_access += ' (no-download)' if file_access[:access] != 'dark'

    return [basic_access] unless file_access[:download] == 'location-based'

    # Here we're using readLocation to mean download location. https://github.com/sul-dlss/cocina-models/issues/258
    [basic_access, "location: #{file_access[:readLocation]}"]
  end

  def same_as_object_access?(file_access)
    (file_access[:access] == cocina.access.access && file_access[:download] == cocina.access.download) ||
      (cocina.access.access == 'citation-only' && file_access[:access] == 'dark')
  end

  def file_access_nodes
    Array(cocina.structural.contains)
      .flat_map { |fs| Array(fs.structural.contains) }
      .map { |file| file.access.to_h }
      .uniq
  end

  def object_level_access
    case cocina.access.access
    when 'citation-only'
      ['citation']
    when 'world'
      world_object_access
    when 'location-based'
      case cocina.access.download
      when 'none'
        ["location: #{cocina.access.readLocation} (no-download)"]
      else
        ["location: #{cocina.access.readLocation}"]
      end
    when 'stanford'
      stanford_object_access
    end
  end

  def stanford_object_access
    case cocina.access.download
    when 'none'
      ['stanford (no-download)']
    when 'location-based'
      # this is an odd case we might want to move away from. See https://github.com/sul-dlss/cocina-models/issues/258
      ['stanford (no-download)', "location: #{cocina.access.readLocation}"]
    else
      ['stanford']
    end
  end

  def world_object_access
    case cocina.access.download
    when 'stanford'
      ['stanford', 'world (no-download)']
    when 'none'
      ['world (no-download)']
    when 'world'
      ['world']
    when 'location-based'
      # this is an odd case we might want to move away from. See https://github.com/sul-dlss/cocina-models/issues/258
      ['world (no-download)', "location: #{cocina.access.readLocation}"]
    end
  end
end
