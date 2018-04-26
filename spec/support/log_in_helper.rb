module LogInControllerHelper
  def sign_in_as(user)
    allow(controller).to receive(:current_user).and_return(user)
    controller.request.env['warden'] = double(:warden, authenticate!: true)
  end
end

module LogInFeatureHelper
  def sign_in_as(user)
    GDS::SSO.test_user = user
    visit '/'
    click_on 'Sign in'
  end

  def sign_out
    User.destroy_all
    GDS::SSO.test_user = nil
  end
end
