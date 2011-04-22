@form_builder
Feature: Formageddon Form Builder
  In order to build rules for contact forms
  As an admin
  I want to be able to give a URL with a contact form and have the app help me build the rules to complete it
  
  Scenario: An admin user submits a URL with no forms
    Given I am logged in as an admin user
    When I go to the admin new contact steps page
    And I fill in "formageddon_formageddon_contact_step_command" with test form page "no forms"
    And I press "Build Rules"
    Then I should see "Found 0 Form(s) on this page:"
    
  Scenario: An admin user submits a URL with one form
    Given I am logged in as an admin user
    When I go to the admin new contact steps page
    And I fill in "formageddon_formageddon_contact_step_command" with test form page "one form"
    And I press "Build Rules"
    Then I should see "Found 1 Form(s) on this page:"
    
  Scenario: An admin user submits a URL with two forms
    Given I am logged in as an admin user
    When I go to the admin new contact steps page
    And I fill in "formageddon_formageddon_contact_step_command" with test form page "two forms"
    And I press "Build Rules"
    Then I should see "Found 2 Form(s) on this page:"
    
    
  Scenario: An admin user submits a URL with one form, sees form fields
    Given I am logged in as an admin user
    When I go to the admin new contact steps page
    And I fill in "formageddon_formageddon_contact_step_command" with test form page "one form"
    And I press "Build Rules"
    Then I should see "mailing_zipCode"
    And I should see "textarea"
    And I should see "message"
    
  Scenario: An admin user submits a URL with one form, configures the form with the default options
    Given I am logged in as an admin user
    And I go to the admin new contact steps page
    And I fill in "formageddon_formageddon_contact_step_command" with test form page "one form"
    And I press "Build Rules"
    When I press "Use This Form"
    Then I should see "Contact Webform Description"
    And I should see "Step 1"    
    And I should see "Step 2"