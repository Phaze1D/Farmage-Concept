EventMixin = require '../../../mixins/event_mixin/event_mixin.coffee'


require './new.jade'

class UnitsNew extends BlazeComponent
  @register 'unitsNew'

  constructor: (args) ->

  mixins: -> [
    EventMixin
  ]

  onCreated: ->
    super
    @showDialog = new ReactiveVar(false)
    @unit = new ReactiveVar([])


  dialogCB: ->
    ret =
      showClick: =>
        @showDialog.set true
      hideClick: =>
        @showDialog.set false

      beforeHide: @onCloseDialog


  onShowDialog: (event) ->
    $(@find('.js-open-dialog')).trigger('click')



  events: ->
    super.concat
      'click .js-show-d': @onShowDialog
