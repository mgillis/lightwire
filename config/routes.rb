Lightwire::Application.routes.draw do
  # The priority is based upon order of creation:
  # first created -> highest priority.

  resources :accounts, :only => :show do
    resources :portfolios, :only => [:index, :show, :create] do
      member do
        post 'stocktrade'
        post 'currencytrade'
        get 'history'
      end

      resources :transactions, :only => [:index, :show]
    end
    
  end

  resources :transactions, :only => [] do
    member do
      post 'execute'
      post 'cancel'
    end
  end

end
