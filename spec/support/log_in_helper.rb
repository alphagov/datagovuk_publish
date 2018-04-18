def sign_in_as(user)
  GDS::SSO.test_user = user
  visit '/'
end
