OrganizationModule = require '../../../../api/collections/organizations/organizations.coffee'

require './card.jade'

class OUserCard extends BlazeComponent
  @register 'OUserCard'

  constructor: (args) ->
    # body...

  email: ->
    @data().ouser.emails[0].address

  permission: (permission) ->
    organ = OrganizationModule.Organizations.findOne(_id: FlowRouter.getParam 'organization_id')
    if organ?
      op = organ.hasUser(@data().ouser._id)
      if op.permission[permission]
        'on'
      else
        'off'
