CardEvents = require '../../../mixins/card_events_mixin.coffee'

require './card.jade'

class ProviderCard extends BlazeComponent
  @register 'ProviderCard'

  mixins: -> [
    CardEvents
  ]

  constructor: (args) ->
    super
    @positions = new ReactiveDict()
    @positions.set('telephones', 0)
    @positions.set('addresses', 0)

  onRendered: ->
    super


  telephones: ->
    tele = @data().provider.telephones
    if tele? and tele.length > 0
      tele

  addresses: ->
    address = @data().provider.addresses
    if address? and address.length > 0
      address

  showTitle: ->
    f = if @data().provider.first_name? then @data().provider.first_name else ''
    l = if @data().provider.last_name? then @data().provider.last_name else ''
    "#{f} #{l}"


  disableLeft: (type) ->
    if @positions.get(type) is 0
      'disabled'

  disableRight: (type) ->
    if @positions.get(type) is @data().provider[type].length - 1
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
