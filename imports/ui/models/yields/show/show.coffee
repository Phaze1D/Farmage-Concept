ShowMixin = require '../../../mixins/show_mixin.coffee'
require './show.jade'

class YieldShow extends ShowMixin
  @register 'YieldShow'

  constructor: (args) ->
    super

  onCreated: ->
    super

  onRendered: ->
    super
    @parentComponent().parentComponent().parentComponent().rightData.set
      update_id: @data().yield._id

  tabs: ->
    ['Information', 'Analytics', 'Reports']

  identifer: ->
    if @data().yield.name? then @data().yield.name else @data().yield._id

  ingredient: ->
    @data().yield.ingredient().fetch()[0]

  unit: ->
    @data().yield.unit().fetch()[0]
