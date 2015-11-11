Rails.application.routes.draw do
  resources :events
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

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
    end
    collection do
      get 'search', to: 'groups#search'
    end
  end

  # Routes for Messages
  resources :messages, only: [:create]

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
    end
    collection do
      get 'get_terms',       to: 'courses#get_terms'
      get 'get_departments', to: 'courses#get_departments'
      get 'get_courses',     to: 'courses#get_courses'
    end
  end

  # Routes for Administration
  get 'admin', to: 'admin#index'
  get 'admin/users', to: 'admin#user_management'
  resources :institutions, only: [:show]
  scope '/admin' do
    resources :institutions, only: [:new, :index, :create, :edit, :update, :destroy]
    resources :messages, only: [:index]
  end

  # Routes for Sessions
  get    'login'  => 'sessions#new'
  post   'login'  => 'sessions#create'
  delete 'logout' => 'sessions#destroy'

  # Routes for Users
  resources :password_resets,     only: [:new, :create, :edit, :update]
  resources :account_activations, only: [:edit]
  get 'register' => 'users#new'
  get 'schedule', to: 'users#schedule'
  resources :users, only: [:index, :create, :show, :edit, :update, :destroy] do
    member do
      post 'promote'
      post 'demote'
      get 'courses'
      get 'groups'
      get 'customize'
    end
  end

  # Routes for Static Pages
  get 'about' => 'static_pages#about'
  get 'terms' => 'static_pages#terms'
  get 'help'  => 'static_pages#help'

  # Home page for logged in Users
  get 'home' => 'home#home'

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
