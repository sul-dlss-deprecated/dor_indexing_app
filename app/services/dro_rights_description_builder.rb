# frozen_string_literal: true

# Rights description builder for items and apos
class DroRightsDescriptionBuilder < RightsDescriptionBuilder
  # @param [Cocina::Models::DRO] cocina_item

  # This overrides the superclass
  # @return [Cocina::Models::DROAccess]
  def object_access
    @object_access ||= cocina.access
  end

  private

  def object_level_access
    super + access_level_from_files.uniq.map { |str| "#{str} (file)" }
  end

  def access_level_from_files
    # dark access doesn't permit any file access
    return [] if object_access.access == 'dark'

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
    (file_access[:access] == object_access.access && file_access[:download] == object_access.download) ||
      (object_access.access == 'citation-only' && file_access[:access] == 'dark')
  end

  def file_access_nodes
    Array(cocina.structural.contains)
      .flat_map { |fs| Array(fs.structural.contains) }
      .map { |file| file.access.to_h }
      .uniq
  end
end
