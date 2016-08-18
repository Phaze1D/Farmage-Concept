EventMixin = require '../../../mixins/event_mixin/event_mixin.coffee'
DialogMixin = require '../../../mixins/dialog_mixin/dialog_mixin.coffee'


require './new.jade'

class YieldsNew extends BlazeComponent
  @register 'yieldsNew'

  constructor: (args) ->

  mixins: -> [
    EventMixin, DialogMixin
  ]


  onCreated: ->
    super


  currentList: (subscription)->
    return @callFirstWith(@, 'currentList', subscription);
