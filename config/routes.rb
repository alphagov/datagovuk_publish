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

  scope '/datasets' do
    # links
    get    ':uuid/*name/links/new',      to: 'datasets/links#new',          as: 'new_dataset_link'
    get    ':uuid/*name/links/:id/edit', to: 'datasets/links#edit',         as: 'edit_dataset_link'
    get    ':uuid/*name/links',          to: 'datasets/links#index',        as: 'dataset_links'
    post   ':uuid/*name/links',          to: 'datasets/links#create'
    patch  ':uuid/*name/links/:id',      to: 'datasets/links#update',       as: 'update_dataset_link'
    delete ':uuid/*name/links/:id',      to: 'datasets/links#destroy',      as: 'delete_dataset_link'

    get    ':uuid/*name/links/:id/confirm_delete', to: 'datasets/links#confirm_delete', as: 'confirm_delete_dataset_link'

    # docs
    get    ':uuid/*name/docs/new',      to: 'datasets/docs#new',        as: 'new_dataset_doc'
    get    ':uuid/*name/docs/:id/edit', to: 'datasets/docs#edit',       as: 'edit_dataset_doc'
    get    ':uuid/*name/docs',          to: 'datasets/docs#index',      as: 'dataset_docs'
    post   ':uuid/*name/docs',          to: 'datasets/docs#create'
    patch  ':uuid/*name/docs/:id',      to: 'datasets/docs#update',     as: 'update_dataset_doc'
    delete ':uuid/*name/docs/:id',      to: 'datasets/docs#destroy',    as: 'delete_dataset_doc'

    get    ':uuid/*name/docs/:id/confirm_delete', to: 'datasets/docs#confirm_delete', as: 'confirm_delete_dataset_doc'

    # licence
    get    ':uuid/*name/licence/new',    to: 'datasets/licences#new',       as: 'new_dataset_licence'
    get    ':uuid/*name/licence/edit',   to: 'datasets/licences#edit',      as: 'edit_dataset_licence'
    post   ':uuid/*name/licences',       to: 'datasets/licences#create',    as: 'create_dataset_licence'
    patch  ':uuid/*name/licence',        to: 'datasets/licences#update',    as: 'update_dataset_licence'

    # location
    get    ':uuid/*name/location/new',   to: 'datasets/locations#new',      as: 'new_dataset_location'
    get    ':uuid/*name/location/edit',  to: 'datasets/locations#edit',      as: 'edit_dataset_location'
    post   ':uuid/*name/locations',      to: 'datasets/locations#create',   as: 'create_dataset_location'
    patch  ':uuid/*name/location',       to: 'datasets/locations#update',    as: 'update_dataset_location'

    # frequency
    get    ':uuid/*name/frequency/new',  to: 'datasets/frequencies#new',    as: 'new_dataset_frequency'
    get    ':uuid/*name/frequency/edit', to: 'datasets/frequencies#edit',   as: 'edit_dataset_frequency'
    post   ':uuid/*name/frequencies',    to: 'datasets/frequencies#create', as: 'create_dataset_frequency'
    patch  ':uuid/*name/frequency',      to: 'datasets/frequencies#update', as: 'update_dataset_frequency'

    # Datasets other
    get    ':uuid/*name/confirm_delete', to: 'datasets#confirm_delete',     as: 'confirm_delete_dataset'
    get    ':uuid/*name/quality',        to: 'datasets#quality',            as: 'dataset_quality'
    post   ':uuid/*name/publish',        to: 'datasets#publish',            as: 'publish_dataset'

    # Datasets CRUD
    get    'new',                        to: 'datasets#new',                as: 'new_dataset'
    get    ':uuid/*name/edit',           to: 'datasets#edit',               as: 'edit_dataset'
    get    ':uuid/*name',                to: 'datasets#show',               as: 'dataset'
    post   '/',                          to: 'datasets#create',             as: 'datasets'
    patch  ':uuid/*name',                to: 'datasets#update',             as: 'update_dataset'
    delete ':uuid/*name',                to: 'datasets#destroy',            as: 'delete_dataset'

  end

  namespace :api do
    get 'sync_beta', to: 'sync#beta'
    get 'locations', to: 'locations#lookup'
    get 'organisations', to: 'organisations#lookup'
  end

  resources :account, only: :show

  get 'tasks', to: 'tasks#my'
  get 'tasks/organisation', to: 'tasks#organisation'

  # FIX: Temporary route, remove me when no longer required
  get 'quality', to: 'home#quality'

  get 'manage', to: 'manage#manage_own'
  get 'manage/organisation', to: 'manage#manage_organisation'
end
