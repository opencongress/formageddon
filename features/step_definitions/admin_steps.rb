Given /^I am an anonymous user$/ do
  visit('/users/sign_out') # ensure that at least
end


Given /^I have one\s+user "([^\"]*)" with password "([^\"]*)"$/ do |email, password|
  User.new(:email => email,
           :password => password,
           :password_confirmation => password).save!
end

Given /^I have one\s+admin user "([^\"]*)" with password "([^\"]*)"$/ do |email, password|
  u = User.new(:email => email,
               :password => password,
               :password_confirmation => password)
  u.save
  u.update_attribute :admin, true
end

Given /^I am logged in as a non\-admin user$/ do
  email = 'not-admin@testing.net'
  password = 'secretpass'

  Given %{I have one user "#{email}" with password "#{password}"}
  And %{I go to login}
  And %{I fill in "user_email" with "#{email}"}
  And %{I fill in "user_password" with "#{password}"}
  And %{I press "Sign in"}
end

Given /^I am logged in as an admin user$/ do
  email = 'admin@testing.net'
  password = 'secretpass'

  Given %{I have one admin user "#{email}" with password "#{password}"}
  And %{I go to login}
  And %{I fill in "user_email" with "#{email}"}
  And %{I fill in "user_password" with "#{password}"}
  And %{I press "Sign in"}
end