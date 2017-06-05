Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  devise_for :publishing_users, controllers: {
      sessions: 'publishing_users/sessions'
    }

  root to: 'tasks#index'

  resources :tasks do
    get 'organisation'
  end

  resources :users
  resources :datasets

  get 'manage', to: 'manage#manage_own'
  get 'manage/organisation', to: 'manage#manage_org'
end
