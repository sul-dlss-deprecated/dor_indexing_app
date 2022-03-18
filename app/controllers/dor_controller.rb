# frozen_string_literal: true

# Main controller of application
class DorController < ApplicationController
  include Dry::Monads[:result]

  class CocinaModelBuildError < StandardError; end

  def reindex
    cocina_with_metadata = indexer.fetch_model_with_metadata
    reindex_object(cocina_with_metadata)
    render status: :ok, plain: "Successfully updated index for #{params[:id]}"
  rescue Dor::Services::Client::NotFoundResponse, Rubydora::RecordNotFound
    render status: :not_found, plain: 'Object does not exist in the repository'
  end

  def reindex_from_cocina
    cocina_with_metadata = build_model_and_metadata(cocina_json: params[:cocina_object].presence,
                                                    created_at: params[:created_at].presence,
                                                    updated_at: params[:updated_at].presence)
    reindex_object(cocina_with_metadata)
    render status: :ok, plain: "Successfully updated index for #{params[:id]}"
  rescue CocinaModelBuildError => e
    request.session # TODO: calling this as a hack to address bad Rails/HB interaction, remove when https://github.com/rails/rails/issues/43922 is fixed
    Honeybadger.notify('Error building Cocina model', context: { druid: params[:id], build_error: e.cause.message }, backtrace: e.cause.backtrace)
    render status: :unprocessable_entity, plain: "Error building Cocina model for #{params[:id]}"
  end

  def delete_from_index
    solr.delete_by_id(params[:id], commitWithin: params.fetch(:commitWithin, 1000).to_i)
    solr.commit unless params[:commitWithin]
    render plain: params[:id]
  end

  private

  def solr
    RSolr.connect(timeout: 120, open_timeout: 120, url: Settings.solrizer_url)
  end

  def build_model_and_metadata(cocina_json:, created_at:, updated_at:)
    model = Cocina::Models.build(JSON.parse(cocina_json))
    metadata = Dor::Services::Client::ObjectMetadata.new(created_at: created_at, updated_at: updated_at)
    Success([model, metadata])
  rescue StandardError
    raise CocinaModelBuildError
  end

  def indexer
    @indexer ||= Indexer.new(solr: solr, identifier: params[:id])
  end

  def reindex_object(cocina_with_metadata)
    @solr_doc = indexer.reindex(
      add_attributes: { commitWithin: params.fetch(:commitWithin, 1000).to_i },
      cocina_with_metadata: cocina_with_metadata
    )
    indexer.commit unless params[:commitWithin] # reindex doesn't commit, but callers of this method may expect the update to be committed immediately
  end
end
