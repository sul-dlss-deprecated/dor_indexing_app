# frozen_string_literal: true

class TitleBuilder
  # @param [Array<Cocina::Models::Title>] titles
  # @returns [String] the title value for Solr
  def self.build(titles)
    title = primary_title(titles) || first_untyped_title(titles) || titles.first
    if title.value
      my_title = title.value
    elsif title.structuredValue
      my_title = title_from_structured_values(title.structuredValue, non_sorting_char_count(title))
    elsif title.parallelValue
      my_title = build(title.parallelValue)
    end
    remove_trailing_punctuation(my_title.strip) if my_title.present?
  end

  def self.title_from_structured_values(structured_values, non_sorting_char_count)
    structured_title = ''
    title_from_part = ''
    structured_values.each do |structured_value|
      # There can be a structuredValue inside a structuredValue.  For example,
      #   a uniform title where both the name and the title have internal StructuredValue
      return title_from_structured_values(structured_value.structuredValue, non_sorting_char_count) if structured_value.structuredValue

      value = structured_value.value&.strip
      next unless value

      case structured_value.type&.downcase
      when 'nonsorting characters'
        non_sort_value = value&.size == non_sorting_char_count ? value : "#{value} "
        if structured_title.present?
          structured_title = "#{structured_title}#{non_sort_value}"
        else
          structured_title = non_sort_value
        end
      when 'part name', 'part number'
        if title_from_part.blank?
          title_from_part = title_from_structured_part(structured_values)
          if structured_title.present?
            structured_title = "#{structured_title.sub(/[ \.,]*$/, '')}. #{title_from_part}. "
          else
            structured_title = "#{title_from_part}. "
          end
        end
      when 'main title', 'title'
        structured_title = "#{structured_title}#{value}"
      when 'subtitle'
        # subtitle is preceded by space colon space, unless it is at the beginning of the title string
        if structured_title.present?
          structured_title = "#{structured_title.sub(/[. :]+$/, '')} : #{value.sub(/^:/, '').strip}"
        else
          structured_title = value.sub(/^:/, '').strip
        end
      # other types:  name, uniform ...
      end
    end
    structured_title
  end
  private_class_method :title_from_structured_values

  def self.remove_trailing_punctuation(title)
    title.sub(/[ \.,;:\/\\]+$/, '')
  end
  private_class_method :remove_trailing_punctuation

  # @param [Array<Cocina::Models::Title>] titles
  # @return [Cocina::Models::Title, nil] title that has status=primary
  def self.primary_title(titles)
    primary_title = titles.find do |title|
      title.status == 'primary'
    end
    return primary_title if primary_title.present?

    # NOTE: structuredValues would only have status primary assigned as a sibling, not as an attribute

    parallel_title_primary = titles.find do |title|
      title.parallelValue&.find do |parallel_title|
        parallel_title.status == 'primary'
      end
    end
    parallel_title_primary
  end
  private_class_method :primary_title

  # @param [Array<Cocina::Models::Title>] titles
  # @return [Cocina::Models::Title, nil] first title that has no type attribute
  def self.first_untyped_title(titles)
    titles.find do |title|
      if title.parallelValue.present?
        title.parallelValue&.find { |parallel_value| parallel_value.type.nil? }
      else
        title.type.nil?
      end
    end
  end
  private_class_method :first_untyped_title

  def self.non_sorting_char_count(title)
    non_sort_note = title.note&.find { |note| note.type&.downcase == 'nonsorting character count' }
    return 0 unless non_sort_note

    non_sort_note.value.to_i
  end
  private_class_method :non_sorting_char_count

  # combine part name and part number:
  #   respect order of occurrence
  #   separated from each other by comma space
  def self.title_from_structured_part(structured_values)
    title_from_part = ''
    structured_values.each do |structured_value|
      case structured_value.type&.downcase
      when 'part name', 'part number'
        if title_from_part&.strip.present?
          title_from_part = "#{title_from_part.sub(/[ \.,]*$/, '')}, #{structured_value.value&.strip}"
        else
          title_from_part = structured_value.value&.strip
        end
      end
    end
    title_from_part
  end
end
