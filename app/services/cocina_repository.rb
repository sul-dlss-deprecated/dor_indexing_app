# frozen_string_literal: true

# Repository for retrieving Cocina objects backed by Dor Services Client.
class CocinaRepository
  # @param [String] druid
  # @return [Cocina::Models::DROWithMetadata,Cocina::Models::CollectionWithMetadata,Cocina::Models::AdminPolicyWithMetadata]
  # @raise [DorIndexing::CocinaRepository::RepositoryError] if the object is not found or other error occurs
  def find(druid)
    Dor::Services::Client.object(druid).find
  rescue Dor::Services::Client::Error => e
    raise DorIndexing::CocinaRepository::RepositoryError, e.message
  end

  # @param [String] druid
  # @return [Array<String>] administrative tags
  # @raise [DorIndexing::CocinaRepository::RepositoryError] if the object is not found or other error occurs
  def administrative_tags(druid)
    Dor::Services::Client.object(druid).administrative_tags.list
  rescue Dor::Services::Client::Error => e
    raise DorIndexing::CocinaRepository::RepositoryError, e.message
  end
end
