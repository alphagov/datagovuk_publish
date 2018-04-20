ActiveAdmin.register User do
  permit_params :primary_organisation_id, :email

  before_create(&:invite!)

  form do |f|
    f.semantic_errors(*f.object.errors.keys)

    f.inputs do
      input :primary_organisation
      input :email
    end

    f.actions
  end
end
