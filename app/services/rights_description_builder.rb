# frozen_string_literal: true

class RightsDescriptionBuilder
  def self.build(cocina)
    new(cocina).build
  end

  def initialize(cocina)
    @cocina = cocina
    @root_access_node = cocina.admin_policy? ? cocina.administrative.defaultAccess : cocina.access
  end

  def build
    cocina.collection? ? rights_descriptions_for_collection : rights_descriptions_for_item_and_apo
  end

  private

  attr_reader :cocina, :root_access_node

  def rights_descriptions_for_collection
    case @root_access_node.access
    when 'world'
      'world'
    else
      'dark'
    end
  end

  def rights_descriptions_for_item_and_apo
    return 'controlled digital lending' if @root_access_node.controlledDigitalLending

    return ['dark'] if @root_access_node.access == 'dark'

    rights = object_level_access
    rights += access_level_from_files.uniq.map { |str| "#{str} (file)" } if @cocina.dro?
    rights
  end

  def access_level_from_files
    # dark access doesn't permit any file access
    return [] if @root_access_node.access == 'dark'

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

    case file_access[:download]
    when 'stanford'
      # Here we're using readLocation to mean download location. https://github.com/sul-dlss/cocina-models/issues/258
      [basic_access, 'stanford']
    when 'location-based'
      # Here we're using readLocation to mean download location. https://github.com/sul-dlss/cocina-models/issues/258
      [basic_access, "location: #{file_access[:readLocation]}"]
    else
      [basic_access]
    end
  end

  def same_as_object_access?(file_access)
    (file_access[:access] == @root_access_node.access && file_access[:download] == @root_access_node.download) ||
      (@root_access_node.access == 'citation-only' && file_access[:access] == 'dark')
  end

  def file_access_nodes
    Array(cocina.structural.contains)
      .flat_map { |fs| Array(fs.structural.contains) }
      .map { |file| file.access.to_h }
      .uniq
  end

  def object_level_access
    case @root_access_node.access
    when 'citation-only'
      ['citation']
    when 'world'
      world_object_access
    when 'location-based'
      case @root_access_node.download
      when 'none'
        ["location: #{@root_access_node.readLocation} (no-download)"]
      else
        ["location: #{@root_access_node.readLocation}"]
      end
    when 'stanford'
      stanford_object_access
    end
  end

  def stanford_object_access
    case @root_access_node.download
    when 'none'
      ['stanford (no-download)']
    when 'location-based'
      # this is an odd case we might want to move away from. See https://github.com/sul-dlss/cocina-models/issues/258
      ['stanford (no-download)', "location: #{@root_access_node.readLocation}"]
    else
      ['stanford']
    end
  end

  def world_object_access
    case @root_access_node.download
    when 'stanford'
      ['stanford', 'world (no-download)']
    when 'none'
      ['world (no-download)']
    when 'world'
      ['world']
    when 'location-based'
      # this is an odd case we might want to move away from. See https://github.com/sul-dlss/cocina-models/issues/258
      ['world (no-download)', "location: #{@root_access_node.readLocation}"]
    end
  end
end
