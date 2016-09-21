ShowMixin = require '../../../mixins/show_mixin.coffee'
require './show.jade'

class OrganizationShow extends ShowMixin
  @register 'OrganizationShow'

  constructor: (args) ->
    super

  onCreated: ->
    super

  onRendered: ->
    super

  tabs: ->
    ['Information', 'Analytics', 'Reports']
