def create_user_and_sign_in
  User.first || create(:user)
  visit '/'
end

def sign_in_user
  User.first || create(:user)
  visit '/'
end
