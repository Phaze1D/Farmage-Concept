ShowMixin = require '../../../mixins/show_mixin.coffee'
require './show.jade'

class ProviderShow extends ShowMixin
  @register 'ProviderShow'

  constructor: (args) ->
    # body...

  onCreated: ->
    super
    organization_id = FlowRouter.getParam("organization_id")
    @autorun =>
      @subscribe "timestamp", organization_id, @data().provider.created_user_id, @data().provider.updated_user_id,
        onStop: (err) ->
          console.log "sub stop #{err}"
        onReady: ->

  onRendered: ->
    super


  tabs: ->
    ['Information', 'Analytics', 'Reports']

  addresses: ->
    if @data().provider.addresses.length > 0
      @data().provider.addresses

  telephones: ->
    if @data().provider.telephones.length > 0
      @data().provider.telephones
