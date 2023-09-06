# frozen_string_literal: true

class OrcidBuilder
  # @param [Array<Cocina::Models::Contributor>] contributors
  # @return [String] the list of contributor ORCIDs to index into solr
  def self.build(contributors)
    new(contributors).build
  end

  def initialize(contributors)
    @contributors = Array(contributors)
  end

  def build
    cited_contributors.filter_map { |contributor| orcidid(contributor) }
  end

  private

  attr_reader :contributors

  # @param [Cocina::Models::Contributor] array of contributors
  # @return [Array<String>] array of contributors who are listed as cited
  # Note that non-cited contributors are excluded.
  def cited_contributors
    contributors.select { |contributor| cited?(contributor) }
  end

  # @param [Cocina::Models::Contributor] contributor to check
  # @return [Boolean] true unless the contributor has a citation status of false
  def cited?(contributor)
    contributor.note.none? { |note| note.type == 'citation status' && note.value == 'false' }
  end

  # @param [Cocina::Models::Contributor] contributor to check
  # @return [String, nil] orcid id including host if present
  def orcidid(contributor)
    identifier = contributor.identifier.find { |id| id.type == 'ORCID' }
    return unless identifier

    # some records have the full ORCID URI in the data, just return it if so, e.g. druid:gf852zt8324
    return identifier.uri if identifier.uri

    URI.join(identifier.source.uri, identifier.value).to_s
  end
end
