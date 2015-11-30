Rails.application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  get 'contact', to: 'contact_requests#new'
  post 'contact', to: 'contact_requests#create'
  get 'faq', to: 'help#faq'
  get 'terms', to: 'help#terms'
  get 'about', to: 'help#about'
  get 'help/*page', to: 'help#show', as: 'help_item'
  get 'help', to: 'help#index'

  post 'dropbox_link', to: 'dropbox_auth#link'
  post 'dropbox_unlink', to: 'dropbox_auth#unlink'
  get 'dropbox_callback', to: 'dropbox_auth#callback'

  # Routes for CAS Auth
  post 'cas_auth', to: 'cas_auth#auth'
  get 'cas_callback', to: 'cas_auth#callback'
  post 'cas_enable', to: 'cas_auth#enable'
  post 'cas_disable', to: 'cas_auth#disable'

  # Routes for events
  resources :events

  # Routes for groups
  resources :group_membership_requests, as: 'gm_request', only: [:new, :create] do
    member do
      post 'approve_request', to: 'group_membership_requests#approve'
      post 'reject_request', to: 'group_membership_requests#reject'
    end
  end
  resources :group_memberships, only: [:destroy, :create]
  resources :groups do
    member do
      post 'kick_member', to: 'groups#kick_member'
      post 'promote_member', to: 'groups#promote_member'
      post 'demote_member', to: 'groups#demote_member'
      get 'requests', to: 'groups#group_requests'
      get 'users', to: 'groups#group_members'
      get 'resources', to: 'groups#resources'
      post 'resources', to: 'groups#create_resource'
      get 'resources/new', to: 'groups#new_resource', as: 'new_resource'
      get 'resources/:resource_id/edit', to: 'groups#edit_resource', as: 'edit_resource'
      get 'resources/:resource_id', to: 'groups#get_resource', as: 'resource'
      patch 'resources/:resource_id', to: 'groups#update_resource'
      put 'resources/:resource_id', to: 'groups#update_resource'
      delete 'resources/:resource_id', to: 'groups#destroy_resource'
    end
    collection do
      get 'search', to: 'groups#search'
    end
  end

  # Routes for Messages and Posts
  resources :messages, only: [:create]
  resources :posts, only: [:create, :edit, :update, :destroy]

  # Routes for Courses
  resources :course_memberships, only: [:destroy, :create] do
    member do
      get 'join_success', to: 'course_memberships#join_success', as: 'join_success'
      delete 'remove_section', to: 'course_memberships#remove_section', as: 'remove_sec'
      post 'add_section', to: 'course_memberships#add_section', as: 'add_sec'
    end
  end
  resources :courses, only: [:index, :show] do
    member do
      get 'users', to: 'courses#course_members'
      get 'info', to: 'courses#info', as: 'get_info'
      get 'enrollment', to: 'courses#enrollment'
      get 'resources', to: 'courses#resources'
      post 'resources', to: 'courses#create_resource'
      get 'resources/new', to: 'courses#new_resource', as: 'new_resource'
      get 'resources/:resource_id/edit', to: 'courses#edit_resource', as: 'edit_resource'
      get 'resources/:resource_id', to: 'courses#get_resource', as: 'resource'
      patch 'resources/:resource_id', to: 'courses#update_resource'
      put 'resources/:resource_id', to: 'courses#update_resource'
      delete 'resources/:resource_id', to: 'courses#destroy_resource'
    end
    collection do
      get 'get_terms',       to: 'courses#get_terms'
      get 'get_departments', to: 'courses#get_departments'
      get 'get_courses',     to: 'courses#get_courses'
    end
  end

  # Routes for Administration
  get 'admin', to: 'admin#index'
  post 'admin', to: 'admin#update_settings'
  get 'admin/users', to: 'admin#user_management'
  get '/institutions/:id/users', to: 'institutions#users', as: 'institution_users'
  scope '/admin' do
    resources :contact_requests, only: [:index, :show, :destroy] do
      member do
        post 'resolve'
      end
    end
    resources :institutions do
      resources :terms, only: [:new, :create, :edit, :update, :destroy] do
        member do
          post 'update_data'
        end
      end
    end
    resources :messages, only: [:index]
  end

  # Routes for Sessions
  get    'login'  => 'sessions#new'
  post   'login'  => 'sessions#create'
  delete 'logout' => 'sessions#destroy'

  # Routes for Users
  resources :password_resets,     only: [:new, :create, :edit, :update]
  resources :account_activations, only: [:edit]
  resources :email_changes, only: [:edit]
  get 'register' => 'users#new'
  get 'schedule', to: 'users#schedule'
  resources :users, only: [:index, :create, :show, :edit, :update, :destroy] do
    member do
      post 'promote'
      post 'demote'
      get 'courses'
      get 'groups'
      get 'accounts'
      get 'customize'
    end
  end

  # Home page for logged in Users
  get 'home' => 'home#home'
  get 'new_index', to: 'index#new_index'

  # You can have the root of your site routed with "root"
  root 'index#index'

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
