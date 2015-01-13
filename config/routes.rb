Rails.application.routes.draw do



  get 'users' => "users#index"

  devise_for :accounts, :controllers => {:registrations => "account/registrations",
   :sessions => "account/sessions" }

  require 'sidekiq/web'
  mount Sidekiq::Web, at: '/sidekiq'

  devise_for :admins, :controllers => {:sessions => "sessions" }

  devise_for :agents, :controllers => {:registrations => "agent/registrations",
   :sessions => "agent/sessions" }

  devise_for :merchants, :controllers => {:registrations => "merchant/registrations",
   :sessions => "merchant/sessions" }

  # root 'welcome#index'
  root 'home#index'
  get '/swmboxa' => "home#swmboxa"
  get '/swmboxm' => "home#swmboxm"
  get '/swmboxapp' => "home#swmboxapp"
  get '/help'     => "home#help"
  get 'about' => "home#about"


  get 'admin' => "admin/dashboard#home", as: :admin_root
  get 'account' => "welcome#index", as: :account_root
  get 'agent' => "agent/dashboard#home", as: :agent_root
  get 'merchant' => "merchant/dashboard#home", as: :merchant_root
  get 'wifi' => "welcome#index", as: :wifi_root
  get "/welcome/generate_verify_code" => "welcome#generate_verify_code"
  get "/merchant/link_from_terminal" => "merchant#link_from_terminal"

  get "/feed_backs/new" => "admin/feed_backs#new"

  namespace :wifi do
    get 'test' => "merchants#test"
    get 'merchant' => "merchants#home"
    get 'login' => "users#login"
    get 'welcome' => "merchants#welcome"
    resources :merchants, only: [:show] do
      collection do
        get :error
      end
    end
    resources :users, only: [] do
      collection do
        post :sign_in
        post :quick_login
        get :login_success
      end
    end
    resources :products, only: [:index,:show]
    resources :surroundings, only: [:index] do
      collection do
        get :load
      end
    end
    resources :activities, only: [:index]
  end

  namespace :admin do
    resources :landings
    resources :bottom_ads

    resources :agents do
      collection do
        get :group_by_agent
        get :group_by_region
        get :region
      end
      member do
        get :merchants
        get :terminals
        post :active
      end
    end
    resources :merchants
    resources :terminals do
      collection do
        get :export
        post :import

        get :normal
        get :unnormal
      end

      member do
        get :update_status
      end

    end
    resources :products
    resources :categories
    resource :auth_message, only: [:show, :update]
    resources :message_warnings, only: :index
    resources :downloads, only: :index
    resources :check_ins, only: :index

    resources :terminal_versions
    resources :app_versions
    resources :feed_backs
    resources :comments, only: [:create, :index, :destroy]
    resources :api_visit_logs, only: :index
    resources :programs do
      collection do
        get :check_channel

      end
      member do
        post :sort_up
        post :sort_down
      end
    end

    resources :televisions, except: :edit
    resources :users, except: [:new, :create, :edit] do
      collection do
        get :unused_users
      end
    end
    resources :cities, except: [:edit]
    resources :exception_logs, except: [:new, :create, :edit]
    resources :point_rules
    resources :television_branches
  end

  namespace :agent do
    resources :merchants, only: :index
  end

  namespace :account do
    get 'signing' => "accounts#signing"
    get 'sign_on_from_signin_or_signup' => "accounts#sign_on_from_signin_or_signup"

    post 'sign_on' => "accounts#sign_on"
  end

  namespace :merchant do
    resources :portal_styles do
      member do
        post :save_order
        post :save_name
        post :change_layout
      end
    end
    resources :banners

    resources :terminals, except: [:show, :destroy] do
      member do
        post :cancelling
      end
    end

    resources :mboxes do
      member do
        post :enable
      end
    end
    resource :merchant_infos, only: [:show] do
      collection do
        get :shop_info
        patch :update_shop_info

        patch :update_password
        patch :change_info
        patch :update_other_base_info
      end
    end
    resources :auth_tokens, only: :index do
      member do
        post :disable
      end
    end

    resources :activities
    resources :products, except: [:new] do
      member do
        patch :set_hot
        delete :unset_hot
      end
    end
  end


  mount API::Entrance => '/api'

  match "/auth/:provider/callback" => "sessions#create", via: [:get, :post]
end
