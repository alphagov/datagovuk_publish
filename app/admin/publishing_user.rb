ActiveAdmin.register PublishingUser do
  permit_params :primary_organisation, :email

  before_create do |publishing_user|
    publishing_user.invite!
  end

  form do |f|
    semantic_errors(*object.errors.keys)

    inputs do
      input :primary_organisation
      input :email
    end

    actions
  end
end
