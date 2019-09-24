# frozen_string_literal: true

Rails.application.routes.draw do
  root to: redirect('/status/all')

  namespace :dor do
    # TODO: Deprecate GET when caml POST can be implemented
    match 'reindex/:pid', action: :reindex, via: %i[get post put]
    match 'delete_from_index/:pid', action: :delete_from_index, via: %i[get post]
    get 'queue_size'
  end
end
