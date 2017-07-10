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
    @canLoadMore = true
    @autorun =>
      @page = Meteor.subscribeWithPagination "ousers", organization_id, 'organization', organization_id, @searchValue.get(), 9,
                onStop: (err) ->
                  console.log "sub stop #{err}"
                onReady: =>
                  @sReady.set true



  ousers: ->
    organ = OrganizationModule.Organizations.findOne(_id: FlowRouter.getParam 'organization_id')
    if organ?
      organ.o_users()

  ready: ->
    if @page.ready()
      organ = OrganizationModule.Organizations.findOne(_id: FlowRouter.getParam 'organization_id')
      if organ?
        count = organ.o_users().count()
      if @previous is count
        @canLoadMore = false
      else
        @canLoadMore = true
        @previous = count
