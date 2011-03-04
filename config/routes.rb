FacebookPageSpamCheck::Application.routes.draw do
  get   'index' => 'search_controller#index', :as => 'index'
  match 'search(/:q)' => 'search_controller#search', :as => 'search'
  get   'show/:id' => 'search_controller#show', :as => 'show'
  
  root :to => 'search_controller#index'
end
