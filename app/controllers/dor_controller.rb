# frozen_string_literal: true

# Main controller of application
class DorController < ApplicationController
  def reindex
    Indexer.load_and_index(solr: solr, identifier: params[:id], commit_within: commit_within_param)
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
    Indexer.reindex(solr: solr, cocina_with_metadata: cocina_with_metadata, commit_within: commit_within_param)
    render status: :ok, plain: "Successfully updated index for #{cocina_with_metadata.externalIdentifier}"
  rescue Cocina::Models::Error => e
    request.session # TODO: calling this as a hack to address bad Rails/HB interaction, remove when https://github.com/rails/rails/issues/43922 is fixed
    hb_context = { cocina: cocina_hash.deep_symbolize_keys, build_error: e.message } # calling #deep_symbolize_keys makes for a more readable hash
    Honeybadger.notify('Error building Cocina model', context: hb_context, backtrace: e.backtrace)
    render status: :unprocessable_entity, plain: "Error building Cocina model from json: '#{e.message}'; cocina=#{cocina_hash.to_json}"
  end

  def delete_from_index
    Indexer.delete(solr: solr, identifier: params[:id], commit_within: commit_within_param)
    render plain: params[:id]
  end

  private

  def solr
    @solr ||= RSolr.connect(timeout: 120, open_timeout: 120, url: Settings.solrizer_url)
  end

  def commit_within_param
    params[:commitWithin]&.to_i
  end

  def build_model_and_metadata(cocina_hash:, created_at:, updated_at:)
    model = Cocina::Models.build(cocina_hash)
    # Lock is required, but we don't know what it is. Since not updating, that is OK.
    Cocina::Models.with_metadata(model, 'unknown_lock', created: DateTime.parse(created_at), modified: DateTime.parse(updated_at))
  end
end
