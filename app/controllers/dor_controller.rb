# frozen_string_literal: true

# Main controller of application
class DorController < ApplicationController
  include Dry::Monads[:result]

  class CocinaModelBuildError < StandardError; end

  def reindex
    cocina_with_metadata = indexer.fetch_model_with_metadata
    reindex_object(cocina_with_metadata)
    render status: :ok, plain: "Successfully updated index for #{params[:id]}"
  rescue Dor::Services::Client::NotFoundResponse
    render status: :not_found, plain: 'Object does not exist in the repository'
  end

  def reindex_from_cocina
    # params[:cocina_object] is itself an ActionController::Parameters instance, hence the #require and #to_unsafe_h
    cocina_hash = params.require(:cocina_object).to_unsafe_h
    cocina_with_metadata = build_model_and_metadata(cocina_hash: cocina_hash,
                                                    created_at: params[:created_at].presence,
                                                    updated_at: params[:updated_at].presence)
    druid = cocina_with_metadata.externalIdentifier
    reindex_object(Success(cocina_with_metadata))
    render status: :ok, plain: "Successfully updated index for #{druid}"
  rescue CocinaModelBuildError => e
    request.session # TODO: calling this as a hack to address bad Rails/HB interaction, remove when https://github.com/rails/rails/issues/43922 is fixed
    hb_context = { cocina: cocina_hash.deep_symbolize_keys, build_error: e.cause.message } # calling #deep_symbolize_keys makes for a more readable hash
    Honeybadger.notify('Error building Cocina model', context: hb_context, backtrace: e.cause.backtrace)
    render status: :unprocessable_entity, plain: "Error building Cocina model from json: '#{e.cause.message}'; cocina=#{cocina_hash.to_json}"
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

  def build_model_and_metadata(cocina_hash:, created_at:, updated_at:)
    model = Cocina::Models.build(cocina_hash)
    # Lock is required, but we don't know what it is. Since not updating, that is OK.
    Cocina::Models.with_metadata(model, 'unknown_lock', created: DateTime.parse(created_at), modified: DateTime.parse(updated_at))
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
