require 'sidekiq/web'

Rails.application.routes.draw do
  root to: 'tasks#my'

  get 'quality', to: 'home#quality'
  get 'dashboard', to: 'home#dashboard', as: 'dashboard'

  mount Sidekiq::Web => '/sidekiq' unless Rails.env.production?

  scope '/datasets' do
    # datafiles
    get ':uuid/*name/datafiles/new', to: 'datasets/datafiles#new', as: 'new_dataset_datafile'
    get ':uuid/*name/datafiles/:id/edit', to: 'datasets/datafiles#edit', as: 'edit_dataset_datafile'
    get ':uuid/*name/datafiles', to: 'datasets/datafiles#index', as: 'dataset_datafiles'
    post ':uuid/*name/datafiles', to: 'datasets/datafiles#create'
    patch ':uuid/*name/datafiles/:id', to: 'datasets/datafiles#update', as: 'update_dataset_datafile'
    delete ':uuid/*name/datafiles/:id', to: 'datasets/datafiles#destroy', as: 'delete_dataset_datafile'

    get ':uuid/*name/datafiles/:id/confirm_delete', to: 'datasets/datafiles#confirm_delete', as: 'confirm_delete_dataset_datafile'

    # docs
    get ':uuid/*name/docs/new', to: 'datasets/docs#new', as: 'new_dataset_doc'
    get ':uuid/*name/docs/:id/edit', to: 'datasets/docs#edit', as: 'edit_dataset_doc'
    get ':uuid/*name/docs', to: 'datasets/docs#index', as: 'dataset_docs'
    post ':uuid/*name/docs', to: 'datasets/docs#create'
    patch ':uuid/*name/docs/:id', to: 'datasets/docs#update', as: 'update_dataset_doc'
    delete ':uuid/*name/docs/:id', to: 'datasets/docs#destroy', as: 'delete_dataset_doc'

    get ':uuid/*name/docs/:id/confirm_delete', to: 'datasets/docs#confirm_delete', as: 'confirm_delete_dataset_doc'

    # licence
    get ':uuid/*name/licence/new', to: 'datasets/licences#new', as: 'new_dataset_licence'
    get ':uuid/*name/licence/edit', to: 'datasets/licences#edit', as: 'edit_dataset_licence'
    post ':uuid/*name/licences', to: 'datasets/licences#create', as: 'create_dataset_licence'
    patch ':uuid/*name/licence', to: 'datasets/licences#update', as: 'update_dataset_licence'

    # location
    get ':uuid/*name/location/new', to: 'datasets/locations#new', as: 'new_dataset_location'
    get ':uuid/*name/location/edit', to: 'datasets/locations#edit', as: 'edit_dataset_location'
    post ':uuid/*name/locations', to: 'datasets/locations#create', as: 'create_dataset_location'
    patch ':uuid/*name/location', to: 'datasets/locations#update', as: 'update_dataset_location'

    # frequency
    get ':uuid/*name/frequency/new', to: 'datasets/frequencies#new', as: 'new_dataset_frequency'
    get ':uuid/*name/frequency/edit', to: 'datasets/frequencies#edit', as: 'edit_dataset_frequency'
    post ':uuid/*name/frequencies', to: 'datasets/frequencies#create', as: 'create_dataset_frequency'
    patch ':uuid/*name/frequency', to: 'datasets/frequencies#update', as: 'update_dataset_frequency'

    # Datasets other
    get ':uuid/*name/confirm_delete', to: 'datasets#confirm_delete', as: 'confirm_delete_dataset'
    get ':uuid/*name/quality', to: 'datasets#quality', as: 'dataset_quality'
    post ':uuid/*name/publish', to: 'datasets#publish', as: 'publish_dataset'

    # Datasets CRUD
    get 'new', to: 'datasets#new', as: 'new_dataset'
    get ':uuid/*name/edit', to: 'datasets#edit', as: 'edit_dataset'
    get ':uuid/*name', to: 'datasets#show', as: 'dataset'
    post '/', to: 'datasets#create', as: 'datasets'
    patch ':uuid/*name', to: 'datasets#update', as: 'update_dataset'
    delete ':uuid/*name', to: 'datasets#destroy', as: 'delete_dataset'
  end

  namespace :api do
    get 'sync-beta', to: 'sync#beta'
  end

  get 'tasks', to: 'tasks#my'
  get 'tasks/organisation', to: 'tasks#organisation'

  get 'manage', to: 'manage#manage_own'
  get 'manage/organisation', to: 'manage#manage_organisation'
end
