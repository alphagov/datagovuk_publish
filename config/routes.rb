Rails.application.routes.draw do
  root to: 'home#index'

  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    passwords: 'users/passwords',
    registrations: 'users/registrations'
  }

  get 'tasks', to: 'tasks#my'
  get 'tasks/organisation', to: 'tasks#organisation'

  resources :datasets do
    get 'show/:id', to: 'datasets#show'

    member do
      resources :links, param: :file_id do
        member do
          get 'confirm_delete', to: 'links#confirm_delete'
        end
      end

      resources :docs, param: :file_id do
        member do
          get 'confirm_delete', to: 'docs#confirm_delete'
        end
      end

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
  get 'quality/:id', to: 'home#org_quality'

  get 'manage', to: 'manage#manage_own'
  get 'manage/organisation', to: 'manage#manage_organisation'

  get 'api/locations', to: 'locations#lookup'

  get 'account/:id', to: 'account#show', as: 'account_show'
end
