Andreord::Application.routes.draw do
  resources :word_sense_graphs
  resources :label_candidates do
    collection do
      get :export
    end
  end

  resources :word_suggestions, only: [:index]
  match '/word_suggestions/:query' => 'word_suggestions#filter', :default => {:filter => :fullsearch}, :as => :word_suggestions_query
  match '/word_suggestions/:filter/:query' => 'word_suggestions#filter', :as => :word_suggestions_query
  
  resources :w,
    :controller => 'word_senses'

  #resources :den_danske_ordbog, 
  #  :controller => 'ddo_mappings'
  #resources :sitemaps, only: [:index]
  #resources :synonyms, only: [:show]

  match '/w/:filter/:id' => 'word_senses#show', :as => :w_filter
  match "/ord/:id" => redirect("/w/"+Rails.configuration.search_filter_default+"/%{id}"), :as => :word_da_redirect
  match "/word/:id" => redirect("/w/"+Rails.configuration.search_filter_default+"/%{id}"), :as => :word_redirect

  match '/find-all/:query' => 'word_senses#search', :default => {:query => :empty}, :as => :without_filter
  match '/find/:filter/:query' => 'word_senses#search', :default => {:query => :empty, :filter => Rails.configuration.search_filter_default}, :as => :find_heading

  match '/synset/:syn_set_id' => 'word_senses#best_for_syn_set', :default => {:filter => Rails.configuration.search_filter_default}, :as => :best_for_syn_set
  match '/s/:syn_set_id/:filter' => 'word_senses#best_for_syn_set', :default => {:filter => Rails.configuration.search_filter_default}, :as => :best_for_syn_set_filter
  match '/begreb/:syn_set_id/:filter' => 'word_senses#best_for_syn_set', :default => {:filter => :full}, :as => :best_for_syn_set_da
  
  match '/disambiguation/:query' => 'disambiguations#show', :default => {:filter => :full}, :as => :disambiguage_word_sense
  match '/disambiguation/:filter/:query' => 'disambiguations#show', :as => :disambiguage_word_sense
  match '/flertydighed/:query' => 'disambiguations#show', :default => {:filter => Rails.configuration.search_filter_default}, :as => :disambiguage_word_sense_da
  match '/flertydighed/:filter/:query' => 'disambiguations#show', :as => :disambiguage_word_sense_da
  
  match '/spelling/:query' => 'wrong_spellings#show', :as => :correct_spelling
  match '/stavning/:query' => 'wrong_spellings#show', :as => :correct_spelling_da
  
  match 'sitemap_index.xml' => 'sitemap_index#show', :as => :sitemap_index

  root :to => 'word_senses#index'


  #match '/:controller(/:action(/:id))'

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
