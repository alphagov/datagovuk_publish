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
    member do
      match 'new/location',  to: 'datasets#location',  via: [:get, :post]
      match 'new/frequency', to: 'datasets#frequency', via: [:get, :post]
      match 'new/addfile',   to: 'datasets#addfile',   via: [:get, :post]
      match 'new/adddoc',    to: 'datasets#adddoc',    via: [:get, :post]
      match 'new/publish',   to: 'datasets#publish',   via: [:get, :post]
    end
  end

  get 'manage', to: 'manage#manage_own'
  get 'manage/organisation', to: 'manage#manage_organisation'

  get 'api/locations', to: 'locations#lookup'

  get 'account/:id', to: 'account#show', as: 'account_show'
end
