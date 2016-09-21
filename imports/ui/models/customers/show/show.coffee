ShowMixin = require '../../../mixins/show_mixin.coffee'
require './show.jade'

class CustomerShow extends ShowMixin
  @register 'CustomerShow'

  constructor: (args) ->
    super

  onCreated: ->
    super
    organization_id = FlowRouter.getParam("organization_id")
    @autorun =>
      @subscribe "sells", organization_id, 'customer', @data().customer._id,
        onStop: (err) ->
          console.log "sub stop #{err}"
        onReady: ->

  onRendered: ->
    super

  tabs: ->
    ['Information', 'Analytics', 'Reports']

  addresses: ->
    if @data().customer.addresses.length > 0
      @data().customer.addresses

  telephones: ->
    if @data().customer.telephones.length > 0
      @data().customer.telephones

  sells: ->
    @data().customer.sells()
