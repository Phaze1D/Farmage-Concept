
require './new.jade'

class ExpensesNew extends BlazeComponent
  @register 'expensesNew'

  constructor: (args) ->

  onCreated: ->
    super
    @showDialog = new ReactiveVar(false)
    @subscription = new ReactiveVar('')
    @currentList = new ReactiveDict()
    @currentList.set 'unit', []
    @currentList.set 'provider', []

  dialogCB: ->
    ret =
      showClick: =>
        @showDialog.set true
      hideClick: =>
        @showDialog.set false

  onShowDialog: (event) ->
    @subscription.set( $(event.currentTarget).find('.resources-b').attr('data-sub') )
    $(@find('.js-open-dialog')).trigger('click')



  events: ->
    super.concat
      'click .js-show-d': @onShowDialog
