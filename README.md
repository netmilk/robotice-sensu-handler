Virtualmaster sensu handler  [![Build Status](https://travis-ci.org/Virtualmaster/sensu-virtualmaster.png)](https://travis-ci.org/Virtualmaster/sensu-virtualmaster)
==================================

Sensu handler for integration with Foreman, Redmine and XMPP/Jabber


## Redmine configuration

You need to add some custom fields and enummerators to Redmine:

*User*

- Ensure you have enabled 'REST service' (Administraton > Settings > Authentication > Enable REST web service)
- Crate user for monitoring eg: 'Sensu monitoring'
- Add this user to all projects where Sensu will be able create new issues
- Login to that user
- Get API key for that user (My account > API acces key in right column > Show)

*Project custom fields*

- max_available_priority
- operator_auto_approval_limit
- supervisor_auto_approval_limit
- max_priority
- billing_customer_url

*Adjust priorities enummerators*

- Immediate
- Urgent
- High
- Normal

## Foreman Hosts metadata

Foreman have to know aobut host's priority class and project in Redmine.

*Add host parametrs for all hosts for which sensu will be able create new issues in Redmine* 

(Edit hosts, Tab parameters)

- redmine_url
- redmine_project
- redmine_priority

eg:

    redmine_url: https://support.vmin.cz/
    redmine_projects: virtualmaster-infrastructure
    redmine_priority: Immediate

## Installation

- clone `git@github.com:Virtualmaster/sensu-virtualmaster.git` into `/etc/sensu/virtualmaster`
- copy `handlers_virtualmaster.json` to `/etc/sensu/conf.d`
- add `virtualmaster` handler to your checks
- copy `virtualmaster.json` to `/etc/sensu/conf.d` and edit hosts and credentials


## Configuration

TODO

## Testing and development

    $ git clone git@github.com:Virtualmaster/sensu-virtualmaster.git
    $ cd sensu-virtualmaster
    $ bundle install


*First pass all tests*


    $ bundle exec rspec


*Then let's start TDD* 


    $ bundle exec guard

    
1. write test and save
2. on file save Guard will run your test
3. see your test failing
4. write the code
5. on file save Guard will run tests 
6. iterate until your tests are passing


### Stubbing HTTP requests

Remote responses are recorded via `curl -is` and saved to `spec/responses/` by
backend. See [WebMock](https://github.com/bblimke/webmock#replaying-raw-responses-recorded-with-curl--is) documentation.

## FUTURE
- move spec helpers to namespace
- refactor static redmine project properties as service json scheme
- make sending XMPP optional and configurable
- make sending SMS optional and configurable
- distribute as Gem
- distribute as deb, rpm
- add Dependency status image https://gemnasium.com/changes