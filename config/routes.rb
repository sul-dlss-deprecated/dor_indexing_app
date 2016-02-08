Rails.application.routes.draw do

  namespace :dor do
    # TODO: Deprecate GET when caml POST can be implemented
    match 'reindex/:pid', action: :reindex, via: [:get, :post, :put]
  end
end
