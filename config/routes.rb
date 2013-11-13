Rails4tutorialSampleApp::Application.routes.draw do
  resources :users
  root 'static_pages#home'
  match '/help',     to: 'static_pages#help',     via: 'get'
  match '/about',    to: 'static_pages#about',    via: 'get'
  match '/contact',  to: 'static_pages#contact',  via: 'get'
  match '/signup',   to: 'users#new',             via: 'get'
  # This route allows the new user signup form to POST to signup_path and have it
  # route to users#create. The problem with having the signup form POST directly
  # to the standard users#create route (/users) is that on signup failure, we
  # re-render the 'new' template in users#create but the URL shows as being /users,
  # since the form POSTed to this URL and the response was the rendered 'new' template
  match '/signup',   to: 'users#create',          via: 'post'
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end
  
  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
