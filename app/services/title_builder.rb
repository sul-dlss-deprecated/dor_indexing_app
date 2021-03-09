# frozen_string_literal: true

class TitleBuilder
  # @param [Array<Cocina::Models::Title>] titles
  # @returns [String] The partial solr document
  def self.build(titles)
    title = titles.first
    if title.value
      title.value
    elsif title.structuredValue
      build_structured(title.structuredValue)
    elsif title.parallelValue
      build(title.parallelValue)
    end
  end

  def self.build_structured(titles)
    title_parts = titles.map do |title|
      join_token = title.type == 'nonsorting characters' ? ' ' : ' : '
      [title.value, join_token]
    end
    last = title_parts.pop
    title_parts.join + last.first # Drops the join token from the last element
  end
end
