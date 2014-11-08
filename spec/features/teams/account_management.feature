@js
Feature: Generating an invoice
  In order to know what I was charged for
  As a customer
  I would like to receive invoice by email

Background:
    Given a team BOB_TEAM exists
    And team BOB_TEAM is subscribed to plan 'monthly' with card '1234'

    Given I am logged in as Bob with email 'bob@bob.com'
    And I am an administrator
    And I am member of team BOB_TEAM

Scenario: Request an invoice
    Given team 'BOB_TEAM' has invoices with data:
      | Field | Value      |
      | Date  | 10/11/2015 |
      | Start | 02/11/2015 |
      | End   | 02/12/2015 |
    When I go to page for "team management"
    And I click 'Send Invoice'
    Then show me the page
    Then I should see 'sent invoice for October to bob@bob.com'
    And the last email should contain:
      | Text                                            |
      | Your card ending in 1234 has been charged       |
      | Bill Date: November 10th, 2015                  |
      | Bill To: bob BOB_TEAM                           |
      | Duration: November 2nd, 2015-December 2nd, 2015 |
      | Description: Enhanced Team Profile              |
      | Price: $99.00                                   |
      | Assembly Made, Inc                              |
      | 548 Market St #45367                            |
      | San Francisco, CA 94104-5401                    |
