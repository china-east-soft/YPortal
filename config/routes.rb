Rails.application.routes.draw do

  devise_for :admins, :controllers => {:registrations => "registrations",
   :sessions => "sessions" }

  devise_for :agents, :controllers => {:registrations => "agent/registrations",
   :sessions => "agent/sessions" }

  devise_for :merchants, :controllers => {:registrations => "merchant/registrations",
   :sessions => "merchant/sessions" }

  root 'welcome#index'
  
  get 'admin' => "admin/dashboard#home", as: :admin_root
  get 'agent' => "welcome#index", as: :agent_root
  get 'merchant' => "merchant/dashboard#home", as: :merchant_root
  get 'wifi' => "welcome#index", as: :wifi_root
  get "/welcome/generate_verify_code" => "welcome#generate_verify_code"

  namespace :wifi do
    get 'merchant' => "merchants#home"
    get 'login' => "users#login"
    get 'welcome' => "merchants#welcome"
    resources :merchants, only: [:show]
    resources :users do
      collection do
        post :sign_in
      end
    end
    resources :products, only: [:index,:show]
  end

  namespace :admin do
    resources :agents
    resources :merchants
    resources :terminals do
      collection do
        get :export
        post :import
      end
    end
    resources :products
  end

  namespace :agent do
  end

  namespace :merchant do
    resources :portal_styles
    resources :banners
    resources :terminals
    resource :merchant_infos do
      collection do
        patch :update_password
        patch :change_info
      end
    end
  end

  mount API::Entrance => '/api'

  match "/auth/:provider/callback" => "sessions#create", via: [:get, :post]

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
