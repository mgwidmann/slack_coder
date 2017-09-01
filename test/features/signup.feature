Feature: Signup New Users
  New users should oauth with github
  New users will be presented with a signup form

  Scenario: Signup
    Given I have a user
    Given I am logged in
    And I visit "/"
    # When I press the coffee button
    # Then I should be served a coffee
