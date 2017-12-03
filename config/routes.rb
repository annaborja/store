Rails.application.routes.draw do
  root 'home#index'

  get 'memberships', to: 'memberships#show', as: 'membership'

  resources :memberships, only: [:create, :new]

  devise_for :users, skip: [:sessions]

  devise_scope :user do
    get 'login', to: 'devise/sessions#new', as: 'new_user_session'
    get 'logout', to: 'devise/sessions#destroy', as: 'destroy_user_session'
    post 'login', to: 'devise/sessions#create', as: 'user_session'
  end
end
