

require './card.jade'

class CustomerCard extends BlazeComponent
  @register 'CustomerCard'

  constructor: (args) ->
    super
    @show = new ReactiveVar(false)
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

  showTitle: ->
    @data().customer.first_name + " " + @data().customer.last_name

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

  onExpand: (event) ->
    @show.set(true)
    $(@find '.show').css display: 'flex'
    $(@find '.show').velocity
      p:
        opacity: 1
      o:
        delay: 250
        duration: 250
        complete: =>
          $(@find '.mCard-content').css visibility: 'hidden'

  onShrink: (event) ->
    $(@find '.mCard-content').css visibility: ''
    $(@find '.show').velocity
      p:
        opacity: 0
      o:
        delay: 250
        duration: 250
        complete: =>
          $(@find '.show').css display: 'none'
          @show.set(false)




  events: ->
    super.concat
      'click .js-nav-left': @onLeft
      'click .js-nav-right': @onRight
      'click .card-expand-action': @onExpand
      'click .card-shrink-action': @onShrink
