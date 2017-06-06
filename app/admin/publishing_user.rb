ActiveAdmin.register PublishingUser do
  permit_params :primary_organisation, :email

  before_create do |publishing_user|
    publishing_user.invite!
  end

  form do |f|
    f.semantic_errors(*f.object.errors.keys)

    f.inputs do
      input :primary_organisation
      input :email
    end

    f.actions
  end
end
