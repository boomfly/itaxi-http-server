Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: '/auth', controllers: {sessions: 'sessions'}


  post 'users/register-device' => 'users#register_device'
  post 'users/unregister-device' => 'users#unregister_device'

  resources :companies
  resources :orders
  resources :users
  # devise_for :users
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'welcome#index'

  get 'orders/my/orders' => 'orders#my_orders'
  post 'orders/:id/take' => 'orders#take'
  post 'orders/:id/waiting' => 'orders#wait'
  post 'orders/:id/on-the-route' => 'orders#on_the_route'
  post 'orders/:id/complete' => 'orders#complete'
  post 'orders/:id/cancel' => 'orders#cancel'


  get 'users/:id/contacts' => 'users#contacts'
  get 'user/manager-dashboard' => 'users#manager_dashboard'

  get 'clients/:phone_number/card' => 'clients#card'
  get 'clients/:phone_number/orders' => 'clients#orders_history'

  get 'chats/:user_id' => 'messages#find_chat'
  post 'chats/:chat_id/send' => 'messages#send_message'
  get 'chats/:chat_id/messages' => 'messages#index'
  post 'chats/:chat_id/mark-as-read' => 'messages#mark_as_read'
  get 'messages/audio/message_id' => 'messages#audio'

  get 'current-user' => 'users#current'

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
