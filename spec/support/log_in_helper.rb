def create_user_and_sign_in
  user
  visit '/'
  click_link 'Sign in'
  fill_in('user_email', with: 'test@localhost.co.uk')
  fill_in('Password', with: 'password')
  click_button 'Sign in'
end

def sign_in_user
  visit '/'
  click_link 'Sign in'
  fill_in('user_email', with: 'test@localhost.co.uk')
  fill_in('Password', with: 'password')
  click_button 'Sign in'
end
