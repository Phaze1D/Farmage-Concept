

require './card.jade'

class ProviderCard extends BlazeComponent
  @register 'ProviderCard'

  constructor: (args) ->
    # body...

  onRendered: ->
    if $(@find '.height-div').height() <= 300
      $(@find '.js-toggle-contact').trigger('click')

  telephones: ->
    tele = @data().provider.telephones
    if tele? and tele.length > 0
      tele

  addresses: ->
    address = @data().provider.addresses
    if address? and address.length > 0
      address

  showContact: (tar) ->

    cd = tar.closest('.middle').find('.contact-div')
    cd.velocity
      p:
        height: cd.find('.height-div').height() + 40
      o:
        duration: 250
        easing: 'ease-in-out'

    tar.find('.more-b').velocity
      p:
        rotateZ: "180deg"
      o:
        duration: 250

    tar.attr('shown', true)

  hideContact: (tar) ->
      cd = tar.closest('.middle').find('.contact-div')
      cd.velocity
        p:
          height: '0'
        o:
          duration: 250
          easing: 'ease-in-out'

      tar.find('.more-b').velocity
        p:
          rotateZ: "0deg"
        o:
          duration: 250

      tar.attr('shown', false)


  onToggleContact: (event) ->
    tar = $(event.currentTarget)

    if tar.attr('shown') is 'true'
      @hideContact(tar)
    else
      @showContact(tar)




  events: ->
    super.concat
      'click .js-toggle-contact': @onToggleContact
