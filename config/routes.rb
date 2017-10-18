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

  get 'tasks', to: 'tasks#my'
  get 'tasks/organisation', to: 'tasks#organisation'

  get 'api/start_legacy_sync', to: 'sync#legacy'

  resources :datasets do
    resources :links do
      get 'confirm_delete', on: :member
    end

    resources :docs do
      get 'confirm_delete', on: :member
    end

    member do
      scope module: :datasets do
        resource :licence
        resource :location
        resource :frequency
      end

      post 'publish',       to: 'datasets#publish'
      get 'confirm_delete', to: 'datasets#confirm_delete'
      get 'quality',        to: 'datasets#quality'
    end
  end

  # FIX: Temporary route, remove me when no longer required
  get 'quality', to: 'home#quality'

  get 'manage', to: 'manage#manage_own'
  get 'manage/organisation', to: 'manage#manage_organisation'

  get 'api/locations', to: 'locations#lookup'
  get 'api/organisations', to: 'organisations#lookup'

  get 'account/:id', to: 'account#show', as: 'account_show'
end
