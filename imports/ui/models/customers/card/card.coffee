

require './card.jade'

class CustomerCard extends BlazeComponent
  @register 'CustomerCard'

  constructor: (args) ->
    super
    @positions = new ReactiveDict()
    @positions.set('telephones', 0)
    @positions.set('addresses', 0)

  onRendered: ->
    super

  telephones: ->
    tele = @data().customer.telephones
    if tele? and tele.length > 0
      tele

  addresses: ->
    address = @data().customer.addresses
    if address? and address.length > 0
      address

  disableLeft: (type) ->
    if @positions.get(type) is 0
      'disabled'

  disableRight: (type) ->
    if @positions.get(type) is @data().customer[type].length - 1
      'disabled'




  onLeft: (event) ->
      tar = $(event.currentTarget)

      unless tar.hasClass('disabled')
        wrap = tar.closest('.nav-wrapper')
        type =  wrap.attr 'data-type'
        position = @positions.get(type) - 1
        wrap.find('.nav-info-mover').velocity
          p:
            translateX: -100*position + "%"
          o:
            duration: 250

        @positions.set(type, position)



  onRight: (event) ->
    tar = $(event.currentTarget)

    unless tar.hasClass('disabled')
      wrap = tar.closest('.nav-wrapper')
      type =  wrap.attr 'data-type'
      position = @positions.get(type) + 1
      wrap.find('.nav-info-mover').velocity
        p:
          translateX: -100*position + "%"
        o:
          duration: 250

      @positions.set(type, position)



  events: ->
    super.concat
      'click .js-nav-left': @onLeft
      'click .js-nav-right': @onRight
