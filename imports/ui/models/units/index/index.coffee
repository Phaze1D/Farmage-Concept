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
    @autorun =>
      @subscribe "units", organization_id,
        onStop: (err) ->
          console.log "sub stop #{err}"
        onReady: ->

  units: ->
    UnitModule.Units.find()
