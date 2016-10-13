IndexMixin = require '../../../mixins/index_mixin.coffee'
UnitModule = require '../../../../api/collections/units/units.coffee'


require './index.jade'

class UnitsIndex extends IndexMixin
  @register 'units.index'

  constructor: (args) ->
    super

  onCreated: ->
    super
    organization_id = FlowRouter.getParam("organization_id")
    @canLoadMore = true
    @autorun =>
        @page = Meteor.subscribeWithPagination "units", organization_id, 'organization', organization_id, 9,
                  onStop: (err) ->
                    console.log "sub stop #{err}"
                  onReady: ->

  units: ->
    UnitModule.Units.find()

  ready: ->
    if @page.ready()
      count = UnitModule.Units.find().count()
      if @previous is count
        @canLoadMore = false
      else
        @canLoadMore = true
        @previous = count
