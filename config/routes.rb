FacebookPageSpamCheck::Application.routes.draw do
  get   'index' => 'search#index', :as => 'index'
  match 'search(/:q(/:page))' => 'search#search', :as => 'search'
  get   'show/:id' => 'search#show', :as => 'show'
  
  root :to => 'search#index'
end
