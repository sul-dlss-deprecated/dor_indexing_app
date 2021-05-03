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

    object_level_access + file_level_access
  end

  def file_level_access
    # dark access doesn't permit any file access
    return [] if cocina.access.access == 'dark'

    file_access_nodes.each_with_object([]) do |fa, file_access|
      next if same_as_object_access?(fa)

      file_access << if fa[:access] != 'dark' && fa[:access] != fa[:download]
                       "#{fa[:access]} (no-download) (file)"
                     else
                       "#{fa[:access]} (file)"
                     end
    end
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
