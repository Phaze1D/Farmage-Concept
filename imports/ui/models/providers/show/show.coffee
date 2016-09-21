ShowMixin = require '../../../mixins/show_mixin.coffee'
require './show.jade'

class ProviderShow extends ShowMixin
  @register 'ProviderShow'

  constructor: (args) ->
    # body...

  onCreated: ->
    super

  onRendered: ->
    super


  tabs: ->
    ['Information', 'Expenses']

  addresses: ->
    if @data().provider.addresses.length > 0
      @data().provider.addresses

  telephones: ->
    if @data().provider.telephones.length > 0
      @data().provider.telephones
