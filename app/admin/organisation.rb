ActiveAdmin.register Organisation do
  permit_params :name, :title, :description, :abbreviation, :replace_by,
    :contact_email, :contact_phone, :contact_name, :foi_email, :foi_phone,
    :foi_name, :foi_web, :category

  form do |f|
    f.semantic_errors

    f.inputs 'Basic Information' do
      input :name
      input :title
      input :description
      input :abbreviation
      input :replace_by
      input :category
    end

    f.inputs 'Contact Information' do
      input :contact_email
      input :contact_phone
      input :contact_name
    end

    f.inputs 'FOI Information' do
      input :foi_email
      input :foi_phone
      input :foi_name
      input :foi_web
    end

    f.actions
  end
end
