ShowMixin = require '../../../mixins/show_mixin.coffee'
require './show.jade'

class InventoryShow extends ShowMixin
  @register 'InventoryShow'

  constructor: (args) ->
    super

  onCreated: ->
    super

  onRendered: ->
    super

  tabs: ->
    ['Information', 'Analytics', 'Reports']

  identifer: ->
    if @data().inventory.name?
      @data().inventory.name
    else
      @data().inventory._id

  product: ->
    @data().inventory.product().fetch()[0]

  date: (date)->
    months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
    "#{months[date.getMonth()]} #{date.getDate()}, #{date.getFullYear()}"

  yields: ->
    yields = @data().inventory.yields()
    if yields.count() > 0
      return yields

  yieldAmount: (yield_id) ->
    for yield_o in @data().inventory.yield_objects
      if yield_o.yield_id is yield_id
        return yield_o.amount_taken

  yieldIdentifer: (_yield) ->
    if _yield.name? then _yield.name else _yield._id
