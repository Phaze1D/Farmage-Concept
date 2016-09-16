require './show.jade'

class CustomerShow extends BlazeComponent
  @register 'CustomerShow'

  constructor: (args) ->
    # body...

  tabs: ->
    ['Information', 'Sells']

  addresses: ->
    if @data().customer.addresses.length > 0
      @data().customer.addresses

  telephones: ->
    if @data().customer.telephones.length > 0
      @data().customer.telephones
