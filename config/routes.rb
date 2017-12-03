Rails.application.routes.draw do
  resources :charges, only: [:new, :create]

  get 'membership', to: 'account#membership', as: 'membership'
  get 'membership/purchase', to: 'account#membership_purchase', as: 'membership_purchase'

  root 'home#index'

  devise_for :users, skip: [:sessions]

  devise_scope :user do
    get 'login', to: 'devise/sessions#new', as: 'new_user_session'
    get 'logout', to: 'devise/sessions#destroy', as: 'destroy_user_session'

    post 'login', to: 'devise/sessions#create', as: 'user_session'
  end
end
