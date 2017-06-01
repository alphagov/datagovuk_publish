Rails.application.routes.draw do
  devise_for :publishing_users, controllers: {
      sessions: 'publishing_users/sessions'
    }
  end
end
