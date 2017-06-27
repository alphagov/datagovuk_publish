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
    get 'show/:id', to: 'datatsets#show'

    member do
      match 'licence',       to: 'datasets#licence',     via: [:post, :put]
      match 'location',      to: 'datasets#location',    via: [:post, :put]
      match 'frequency',     to: 'datasets#frequency',   via: [:post, :put]

      resources :datafiles, as: 'files', param: :file_id
      resources :datafiles, as: 'documents', param: :doc_id

      get 'new/licence',    to: 'datasets#licence'
      get 'new/location',   to: 'datasets#location'
      get 'new/frequency',  to: 'datasets#frequency'
      get 'edit/licence',   to: 'datasets#licence'
      get 'edit/location',  to: 'datasets#location'
      get 'edit/frequency', to: 'datasets#frequency'
      match 'publish',      to: 'datasets#publish',   via: [:get, :post]
      get 'confirm_delete', to: 'datasets#confirm_delete'
    end
  end

  get 'manage', to: 'manage#manage_own'
  get 'manage/organisation', to: 'manage#manage_organisation'

  get 'api/locations', to: 'locations#lookup'

  get 'account/:id', to: 'account#show', as: 'account_show'
end
