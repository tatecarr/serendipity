Serendipity::Application.routes.draw do
  
  resources :relationship_categories


  resources :dbpedia_logs


  resources :dbpedia_infos


  resources :things


  resources :relationship_types


  resources :entity_types


  resources :places
  match 'gnp' => 'places#get_nearby_places'
  match 'google_gnp' => 'places#get_google_nearby_places'
  match 'nearby_connections' => 'places#get_nearby_connections'

  resources :tmp_lat_longs


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
  root :to => 'home#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
  match 'home/user_mgmt' => 'home#user_mgmt'
  match 'home/my_photos' => 'home#my_photos'
  match 'home/my_feed' => 'home#my_feed'
  match 'home/locations' => 'home#locations'
  match 'home/my_friends' => 'home#my_friends'
  match 'home/linked_data' => 'home#linked_data'
  match 'home/movie_info' => 'home#movie_info'

  match 'home/serendipities' => 'home#serendipities'
  match 'home/relationships' => 'home#relationships'
  match 'home/delete_all_my_stuff' => 'home#delete_all_my_stuff'


  devise_for :users, :controllers => { :omniauth_callbacks => "omniauth_callbacks" }

  devise_scope :user do
    get "login", :to => "devise/sessions#new"
    delete 'logout', :to => 'devise/sessions#destroy'
  end


end
