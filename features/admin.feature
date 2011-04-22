Feature: Formageddon Admin
  In order to build rules for contact forms
  As an admin
  I want to be able to access the admin area

  Scenario: An admin user should be able to log in
    Given I am logged in as an admin user
    Then I should see "Signed in successfully"
    
  Scenario: Anonymous user should not be able to build form rules
    Given I am an anonymous user
    When I go to the admin new contact steps page
    Then I should not see "Build Contact Steps"
  
  Scenario: Non-admin user should not be able to build form rules
    Given I am logged in as a non-admin user
    When I go to the admin new contact steps page
    Then I should not see "Build Contact Steps"
    
  Scenario: An admin user should be able to access admin index
    Given I am logged in as an admin user
    When I go to the admin new contact steps page
    Then I should see "Build Contact Steps"