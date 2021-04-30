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

    NameBuilder.build(contributor.name).first
  end

  def primary_contributor
    flat_contributors.find { |contributor| contributor.status == 'primary' }
  end

  def flat_contributors
    @flat_contributors ||= contributors.flat_map { |contributor| contributor.parallelContributor || contributor }
  end
end
