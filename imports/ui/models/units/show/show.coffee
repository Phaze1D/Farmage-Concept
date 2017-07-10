ShowMixin = require '../../../mixins/show_mixin.coffee'
require './show.jade'

class UnitShow extends ShowMixin
  @register 'UnitShow'

  constructor: (args) ->
    super

  onCreated: ->
    super

  onRendered: ->
    super
    @autorun =>
      @parentComponent().parentComponent().parentComponent().rightData.set
        update_id: @data().unit._id
        parent_id: @data().unit.unit_id

  tabs: ->
    ['Information', 'Analytics', 'Reports']

  tracking: ->
    if @data().unit.tracking then "On" else "Off"

  parent: ->
    @data().unit.unit().fetch()[0]
