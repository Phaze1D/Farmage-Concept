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
      parent = FlowRouter.getQueryParam('parent')
      parent_id = FlowRouter.getQueryParam('parent_id')
      @page = Meteor.subscribeWithPagination "units", organization_id, parent, parent_id, @searchValue.get(), 9,
                onStop: (err) ->
                  console.log "sub stop #{err}"
                onReady: ->
      @pReady.set @page.ready()

  units: ->
    UnitModule.Units.find({}, {sort: name: 1})

  ready: ->
    if @page.ready()
      count = UnitModule.Units.find().count()
      if @previous is count
        @canLoadMore = false
      else
        @canLoadMore = true
        @previous = count
