Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  devise_for :publishing_users, controllers: {
      sessions: 'publishing_users/sessions'
    }
end
