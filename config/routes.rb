Rails.application.routes.draw do
  root to: redirect('/is_it_working')

  namespace :dor do
    # TODO: Deprecate GET when caml POST can be implemented
    match 'reindex/:pid', action: :reindex, via: [:get, :post, :put]
    get 'queue_size'
  end
end
