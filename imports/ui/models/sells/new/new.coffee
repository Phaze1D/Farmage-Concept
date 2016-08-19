
DialogMixin = require '../../../mixins/dialog_mixin/dialog_mixin.coffee'

require './new.jade'


class SellsNew extends BlazeComponent
  @register 'sellsNew'

  mixins: -> [
    DialogMixin
  ]

  constructor: (args) ->
    # body...

  currentList: (subscription)->
    return @callFirstWith(@, 'currentList', subscription);

  
