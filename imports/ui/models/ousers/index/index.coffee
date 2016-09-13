IndexMixin = require '../../../mixins/index_mixin.coffee'
OrganizationModule = require '../../../../api/collections/organizations/organizations.coffee'


require './index.jade'

class OUsersIndex extends IndexMixin
  @register 'ousers.index'

  constructor: (args) ->
    super

  onCreated: ->
    super
    organization_id = FlowRouter.getParam("organization_id")
    @autorun =>
      @subscribe "ousers", organization_id,
        onStop: (err) ->
          console.log "sub stop #{err}"
        onReady: ->

  ousers: ->
    organ = OrganizationModule.Organizations.findOne(_id: FlowRouter.getParam 'organization_id')
    if organ?
      organ.o_users()
