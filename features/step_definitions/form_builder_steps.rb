Given /^an admin user has configured a one-step form$/ do
  Given I am logged in as an admin user
  And I go to the admin new contact steps page
  And I fill in "formageddon_formageddon_contact_step_command" with test form page "one form"
  And I press "Build Rules"
  When I press "Use This Form"
end