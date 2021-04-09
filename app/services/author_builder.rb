# frozen_string_literal: true

class AuthorBuilder
  ALLOWED_ROLES = %w[Author creator].freeze

  # @param [Array<Cocina::Models::Contributor>] contributors
  # @return [String] the author value for Solr
  def self.build(contributors)
    new(contributors).build
  end

  def initialize(contributors)
    @contributors = Array(contributors)
  end

  def build
    contributor = primary_contributor || flat_contributors.first
    build_contributor(contributor)
  end

  private

  attr_reader :contributors

  def build_contributor(contributor)
    return if contributor.nil?

    names = flat_names_for(contributor)
    name = display_name_for(names) || primary_name_for(names) || names.first
    build_name(name)
  end

  def build_name(name)
    if name.groupedValue
      name.groupedValue.find { |grouped_value| grouped_value.type == 'name' }&.value
    elsif name.structuredValue
      name_part = joined_name_parts(name, 'name', '. ').presence
      surname = joined_name_parts(name, 'surname', ' ')
      forename = joined_name_parts(name, 'forename', ' ')
      terms_of_address = joined_name_parts(name, 'term of address', ', ')
      life_dates = joined_name_parts(name, 'life dates', ', ')
      activity_dates = joined_name_parts(name, 'activity dates', ', ')
      joined_name = name_part || join_parts([surname, forename], ', ')
      joined_name = join_parts([joined_name, terms_of_address], ' ')
      joined_name = join_parts([joined_name, life_dates], ', ')
      join_parts([joined_name, activity_dates], ', ')

    else
      name.value
    end
  end

  def primary_contributor
    flat_contributors.find { |contributor| contributor.status == 'primary' }
  end

  def flat_contributors
    @flat_contributors ||= contributors.flat_map { |contributor| contributor.parallelContributor || contributor }
  end

  def display_name_for(names)
    names.find { |name| name.type == 'display' }
  end

  def primary_name_for(names)
    names.find { |name| name.status == 'primary' }
  end

  def flat_names_for(contributor)
    contributor.name.flat_map { |name| name.parallelValue || name }
  end

  def joined_name_parts(name, type, joiner)
    join_parts(name.structuredValue.select { |structured_value| structured_value.type == type }.map(&:value), joiner)
  end

  def join_parts(parts, joiner)
    parts.reject(&:blank?).join(joiner)
  end
end
