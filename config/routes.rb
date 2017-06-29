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
      resources :files,     controller: 'datafiles', param: :file_id
      resources :documents, controller: 'datafiles', param: :file_id

      scope module: :datasets do
        resources :licence
        resources :location
        resources :frequency
      end

      match 'publish',      to: 'datasets#publish',   via: [:get, :post]
      get 'confirm_delete', to: 'datasets#confirm_delete'
    end
  end

  get 'manage', to: 'manage#manage_own'
  get 'manage/organisation', to: 'manage#manage_organisation'

  get 'api/locations', to: 'locations#lookup'

  get 'account/:id', to: 'account#show', as: 'account_show'
end
