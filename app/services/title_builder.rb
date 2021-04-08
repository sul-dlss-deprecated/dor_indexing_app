# frozen_string_literal: true

class TitleBuilder
  # @param [Array<Cocina::Models::Title>] titles
  # @returns [String] the title value for Solr
  def self.build(titles)
    cocina_title = primary_title(titles) || first_untyped_title(titles) || titles.first
    result = if cocina_title.value
               cocina_title.value
             elsif cocina_title.structuredValue
               title_from_structured_values(cocina_title.structuredValue, non_sorting_char_count(cocina_title))
             elsif cocina_title.parallelValue
               build(cocina_title.parallelValue)
             end
    remove_trailing_punctuation(result.strip) if result.present?
  end

  # rubocop:disable Metrics/BlockLength
  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/PerceivedComplexity
  # @param [Array<Cocina::Models::StructuredValue>] structured_values - the individual pieces of a structuredValue to be combined
  # @param [Integer] the length of the non_sorting_characters
  # @returns [String] the title value from combining the pieces of the structured_values according to type and order of occurrence
  def self.title_from_structured_values(structured_values, non_sorting_char_count)
    structured_title = ''
    part_name_number = ''
    # combine pieces of the cocina structuredValue into a single title
    structured_values.each do |structured_value|
      # There can be a structuredValue inside a structuredValue.  For example,
      #   a uniform title where both the name and the title have internal StructuredValue
      return title_from_structured_values(structured_value.structuredValue, non_sorting_char_count) if structured_value.structuredValue

      value = structured_value.value&.strip
      next unless value

      # additional types:  name, uniform ...
      case structured_value.type&.downcase
      when 'nonsorting characters'
        non_sort_value = value&.size == non_sorting_char_count ? value : "#{value} "
        structured_title = if structured_title.present?
                             "#{structured_title}#{non_sort_value}"
                           else
                             non_sort_value
                           end
      when 'part name', 'part number'
        if part_name_number.blank?
          part_name_number = part_name_number(structured_values)
          structured_title = if structured_title.present?
                               "#{structured_title.sub(/[ .,]*$/, '')}. #{part_name_number}. "
                             else
                               "#{part_name_number}. "
                             end
        end
      when 'main title', 'title'
        structured_title = "#{structured_title}#{value}"
      when 'subtitle'
        # subtitle is preceded by space colon space, unless it is at the beginning of the title string
        structured_title = if structured_title.present?
                             "#{structured_title.sub(/[. :]+$/, '')} : #{value.sub(/^:/, '').strip}"
                           else
                             structured_title = value.sub(/^:/, '').strip
                           end
      end
    end
    structured_title
  end
  # rubocop:enable Metrics/BlockLength
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/PerceivedComplexity
  private_class_method :title_from_structured_values

  def self.remove_trailing_punctuation(title)
    title.sub(%r{[ .,;:/\\]+$}, '')
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

    titles.find do |title|
      title.parallelValue&.find do |parallel_title|
        parallel_title.status == 'primary'
      end
    end
  end
  private_class_method :primary_title

  # @param [Array<Cocina::Models::Title>] titles
  # @return [Cocina::Models::Title, nil] first title that has no type attribute
  def self.first_untyped_title(titles)
    titles.find do |title|
      if title.parallelValue.present?
        title.parallelValue.find { |parallel_value| parallel_value.type.nil? }
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
  def self.part_name_number(structured_values)
    title_from_part = ''
    structured_values.each do |structured_value|
      case structured_value.type&.downcase
      when 'part name', 'part number'
        value = structured_value.value&.strip
        next unless value

        title_from_part = if title_from_part.strip.present?
                            "#{title_from_part.sub(/[ .,]*$/, '')}, #{value}"
                          else
                            value
                          end
      end
    end
    title_from_part
  end
  private_class_method :part_name_number
end
