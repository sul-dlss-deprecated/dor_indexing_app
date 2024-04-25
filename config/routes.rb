# frozen_string_literal: true

Rails.application.routes.draw do
  root to: redirect('/status/all')

  namespace :dor do
    # TODO: Deprecate GET when caml POST can be implemented
    # match 'reindex/:id', action: :reindex, via: %i[get post put]
    # put 'reindex_from_cocina', action: :reindex_from_cocina
    # match 'delete_from_index/:id', action: :delete_from_index, via: %i[get post]
    get 'queue_size'
  end
end
