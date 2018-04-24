def sign_in_as(user)
  if respond_to? :controller
    allow(controller).to receive(:current_user).and_return(user)
    controller.request.env['warden'] = double(:warden, authenticate!: true)
  end

  if respond_to? :visit
    GDS::SSO.test_user = user
    visit '/'
  end
end
