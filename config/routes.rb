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
      match 'new/licence', to: 'dataset#licence', via: [:get, :post]
      match 'new/location', to: 'dataset#location', via: [:get, :post]
      match 'new/frequency', to: 'dataset#frequency', via: [:get, :post]
      match 'new/addfile', to: 'dataset#addfile', via: [:get, :post]
      match 'new/adddoc', to: 'dataset#adddoc', via: [:get, :post]
      match 'new/publish', to: 'dataset#publish', via: [:get, :post]
    end
  end

  get 'manage', to: 'manage#manage_own'
  get 'manage/organisation', to: 'manage#manage_organisation'

  get 'api/locations', to: 'locations#lookup'

  get 'account/:id', to: 'account#show', as: 'account_show'
end
