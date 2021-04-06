# frozen_string_literal: true

class TitleBuilder
  # @param [Array<Cocina::Models::Title>] titles
  # @returns [String] the title value for Solr
  def self.build(titles)
    title = primary_title(titles) || titles.first
    if title.value
      my_title = title.value
    elsif title.structuredValue
      my_title = build_structured(title.structuredValue)
    elsif title.parallelValue
      my_title = build(title.parallelValue)
    end
    remove_trailing_punctuation(my_title.strip).strip if my_title.present?
  end

  def self.build_structured(titles)
    title_parts = titles.map do |title|
      if title.structuredValue
        [build_structured(title.structuredValue), '']
      else
        [title.value, join_token(title.type)]
      end
    end
    last = title_parts.pop
    title_parts.join + last.first # Drops the join token from the last element
  end
  private_class_method :build_structured

  def self.join_token(type)
    case type
    when 'nonsorting characters'
      ' '
    when 'subtitle'
      '. '
    when 'part number'
      ', '
    else
      ' : '
    end
  end
  private_class_method :join_token

  def self.remove_trailing_punctuation(title)
    title.gsub(/[\.,;:\/\\]$/, '')
  end
  private_class_method :remove_trailing_punctuation

  # @param [Array<Cocina::Models::Title>] titles
  # @reaturn [Cocina::Models::Title, nil] title that has status=primary
  def self.primary_title(titles)
    primary_title = titles.find do |title|
      title.status == 'primary'
    end
    return primary_title if primary_title.present?

    parallel_title_primary = titles.find do |title|
      title.parallelValue&.find do |parallel_title|
        parallel_title.status == 'primary'
      end
    end
    parallel_title_primary
  end
  private_class_method :primary_title
end
