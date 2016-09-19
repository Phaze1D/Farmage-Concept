ShowMixin = require '../../../mixins/show_mixin.coffee'
require './show.jade'

class CustomerShow extends ShowMixin
  @register 'CustomerShow'

  constructor: (args) ->
    # body...

  onCreated: ->
    super

  onRendered: ->
    super


  tabs: ->
    ['Information', 'Sells']

  addresses: ->
    if @data().customer.addresses.length > 0
      @data().customer.addresses

  telephones: ->
    if @data().customer.telephones.length > 0
      @data().customer.telephones
