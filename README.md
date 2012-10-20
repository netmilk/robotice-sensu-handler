Virtualmaster sensu handler
==================================

Sensu handler for integration with Foreman, Redmine and XMPP/Jabber


## Redmine configuration

You need to add some custom fields and enummerators to Redmine:

*Project custom fields*

- max_available_priority
- operator_auto_aprooval_limit
- supervisor_auto_aprooval_limit
- max_available_priority
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


## Configuration

TODO

## Testing and development

TODO








