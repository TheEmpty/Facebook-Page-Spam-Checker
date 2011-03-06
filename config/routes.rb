FacebookPageSpamCheck::Application.routes.draw do
  get 'about/people', :as => 'about_people'
  get 'about/project', :as => 'about_project'
  get 'about/process' => 'about#about_process', :as => 'about_process'

  get   'index' => 'search#index', :as => 'index'
  match 'search(/:q(/:page))' => 'search#search', :as => 'search'
  get   'show/:id' => 'search#show', :as => 'show'
  
  root :to => 'search#index'
end
