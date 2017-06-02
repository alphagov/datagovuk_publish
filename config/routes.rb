Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  devise_for :publishing_users, controllers: {
      sessions: 'publishing_users/sessions'
    }

  resources :tasks do
    get 'organisation'
  end

  resources :users
  resources :datasets

  get 'manage', to: :manage_own
  get 'manage/organisation', to: :manage_org
end
