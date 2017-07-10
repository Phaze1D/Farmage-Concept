OrganizationModule = require '../../../../api/collections/organizations/organizations.coffee'
ShowMixin = require '../../../mixins/show_mixin.coffee'
require './show.jade'

class OUserShow extends ShowMixin
  @register 'OUserShow'

  constructor: (args) ->
    super

  onCreated: ->
    super

  onRendered: ->
    super
    @parentComponent().parentComponent().parentComponent().rightData.set
      update_id: @data().ouser._id

  tabs: ->
    ['Information', 'Analytics', 'Reports']

  email: ->
    @data().ouser.emails[0].address

  permission: (permission) ->
    organ = OrganizationModule.Organizations.findOne(_id: FlowRouter.getParam 'organization_id')
    if organ?
      op = organ.hasUser(@data().ouser._id)
      if op.permission[permission]
        true
      else
        false

  addresses: ->
    if @data().ouser.profile.addresses.length > 0
      @data().ouser.profile.addresses

  telephones: ->
    if @data().ouser.profile.telephones.length > 0
      @data().ouser.profile.telephones
