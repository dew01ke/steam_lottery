Rails.application.routes.draw do

  #Профиль
  get 'profile/addfunds' => 'profile#addFunds'
  get 'profile/lastoperations' => 'profile#lastOperations'
  get 'profile/cashout' => 'profile#cashOut'
  get 'profile' => 'profile#index'
  post 'profile' => 'profile#setUpTradeOfferLink'

  #Авторизация и все действия с ней
  get 'openid/index'
  get 'openid/start'
  get 'openid/complete'
  get 'auth/logout'
  post 'auth' => 'auth#resend'

  #Приватный Апи - гейтвей
  get 'gateway/getgrid'
  get 'gateway/getslots/:lotid' => 'gateway#getslots'
  get 'gateway/getending'
  get 'gateway/buyslot/:lotid/:slotid' => 'gateway#buyslot'
  get 'gateway/getinventory/:appid'  => 'gateway#getinventory'
  post 'gateway/addfunds' => 'tradeoffer#sendTradeOffer'

  #Отдельный лот с вещью
  get 'lot/:lotid' => 'lot#draw'


  #testing routes below
  get 'id64/:api_key/:steamlogin' => 'papi#id64'
  get 'backpackAppid/:steamid64/:api_key/:appid' => 'papi#backpackAppid'
  get 'backpackLogin/:steamlogin/:appid' => 'papi#backpackLogin'
  get 'backpack/:steamid64/:appid' => 'papi#backpack'
  get 'userinfo/:steamid64/:api_key' => 'papi#userinfo'
  get 'pricebyhash/:appid/:market_hash_name' => 'papi#pricebyhash'
  get 'asset/:api_key/:appid' => 'papi#asset'
  get 'gateway/testgateway/:lotid' => 'gateway#testgateway'
  get 'gateway/testbuy/:market_hash_name' => 'gateway#testbuy'
  get 'profile/update'
  get 'stats/teststats'
  get 'clear' => 'tradeoffer#clearNotification'
  get 'acception' => 'tradeoffer#checkAcception'
  get 'lotcancel/:gridid' => 'admin#cancel'
  get 'editrange/:slotid/:minprice/:maxprice' => 'admin#editrange'
  get 'admin/testadminstats'


  root :to => 'application#index'
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
