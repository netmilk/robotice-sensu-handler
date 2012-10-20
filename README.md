Virtualmaster sensu handler
==================================

Sensu handler for integration with Foreman, Redmine and XMPP/Jabber


## Redmine configuration

You need to add some custom fields and enummerators to Redmine:

*Project custom fields*

- max_available_priority
- operator_auto_approval_limit
- supervisor_auto_approval_limit
- max_priority
- billing_customer_url

*User custom fields*

- billing_provider_url
- billing_customer_url

*Priorities enummerators*

- Immediate
- Urgent
- High
- Normal

## Foreman Hosts metadata

Foreman have to know aobut host's priority class and project in Redmine.

*Add host parametrs* 

(Edit hosts, Tab parameters)

- redmine_project_url
- redmine_priority_id

eg:

    redmine_project_url: https://redmine.vmin.cz/projects/mng-magiclab.json
    redmine_priority: Immediate

## Installation

TODO

## Configuration

TODO

## Testing and development

    $ git clone git@github.com:Virtualmaster/sensu-virtualmaster.git
    $ cd sensu-virtualmaster
    $ bundle install
    $ bundle exec guard

    
1. write test and save
2. on save Guard will run your test
3. see your test failing
4. write the code
5. on save Guard will run tests 
6. iterate until your tests are passing

    