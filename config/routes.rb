Rails.application.routes.draw do
  get 'home/index'

  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  devise_for :publishing_users, controllers: {
      sessions: 'publishing_users/sessions'
    }

  resources :tasks do
    get 'organisation'
  end

  resources :users
  resources :datasets

  root to: 'home#index'
  get 'manage', to: 'manage#manage_own'
  get 'manage/organisation', to: 'manage#manage_org'
end
