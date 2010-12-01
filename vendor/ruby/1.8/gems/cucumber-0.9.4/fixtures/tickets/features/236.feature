Feature: Unsubstituted argument placeholder 

  Scenario Outline: See Annual Leave Details (as Management & Human Resource)
    Given the following users exist in the system
      | name  | email           | role_assignments | group_memberships |
      | Jane  | jane@fmail.com  | <role>           | Sales (manager)   |
      | Max   | max@fmail.com   |                  | Sales (member)    |
      | Carol | carol@fmail.com |                  | Sales (member)    |
      | Cat   | cat@fmail.com   |                  |                   |

    Examples:
      | role           |
      | HUMAN RESOURCE |
