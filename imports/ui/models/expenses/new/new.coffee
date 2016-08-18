DialogMixin = require '../../../mixins/dialog_mixin/dialog_mixin.coffee'

require './new.jade'

class ExpensesNew extends BlazeComponent
  @register 'expensesNew'

  mixins: -> [
    DialogMixin
  ]

  onCreated: ->
    super

  currentList: (subscription)->
    return @callFirstWith(@, 'currentList', subscription);
