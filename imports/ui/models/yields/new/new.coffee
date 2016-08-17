EventMixin = require '../../../mixins/event_mixin/event_mixin.coffee'

require './new.jade'

class YieldsNew extends BlazeComponent
  @register 'yieldsNew'

  constructor: (args) ->

  mixins: -> [
    EventMixin
  ]


  onCreated: ->
    super
    @showDialog = new ReactiveVar(false)
    @subscription = new ReactiveVar()


  dialogCB: ->
    ret =
      showClick: =>
        @showDialog.set true
      hideClick: =>
        @showDialog.set false

      beforeHide: @onCloseDialog


  onShowDialog: (event) ->
    @subscription.set( $(event.currentTarget).find('.resources-b').attr('data-sub') )
    $(@find('.js-open-dialog')).trigger('click')



  events: ->
    super.concat
      'click .js-show-d': @onShowDialog
