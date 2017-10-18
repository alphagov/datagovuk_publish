require 'sidekiq/web'

Rails.application.routes.draw do
  root to: 'home#index'

  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    passwords: 'users/passwords',
    registrations: 'users/registrations'
  }

  mount Sidekiq::Web => '/sidekiq' unless Rails.env.production?

  resources :datasets do
    member do
      post 'publish',       to: 'datasets#publish'
      get 'confirm_delete', to: 'datasets#confirm_delete'
      get 'quality',        to: 'datasets#quality'
    end

    scope module: :datasets do
      resource :licence
      resource :location
      resource :frequency

      resources :links do
        get 'confirm_delete', on: :member
      end

      resources :docs do
        get 'confirm_delete', on: :member
      end
    end
  end

  namespace :api do
    get 'start_legacy_sync', to: 'sync#legacy'
    get 'locations', to: 'locations#lookup'
    get 'organisations', to: 'organisations#lookup'
  end

  resource :account, only: :show

  get 'tasks', to: 'tasks#my'
  get 'tasks/organisation', to: 'tasks#organisation'

  # FIX: Temporary route, remove me when no longer required
  get 'quality', to: 'home#quality'

  get 'manage', to: 'manage#manage_own'
  get 'manage/organisation', to: 'manage#manage_organisation'
end
