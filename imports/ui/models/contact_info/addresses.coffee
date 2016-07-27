
require './addresses.jade'

class AddressAdd extends BlazeComponent
  @register 'address.add'

  constructor: (args) ->

  onCreated: ->
    super
    @iconType = new ReactiveVar 'add_circle'

  onRendered: ->
    super

  onAdd: (event) ->
    @iconType.set 'remove_circle'
    $(event.target)
    .closest('.add-contact-info-b')
    .toggleClass('js-add-address-b')
    .toggleClass('js-remove-address-b')
    $(@find('.icon-button')).css color: '#FF3D00'
    $(@find('.contact-info-inputs')).animate
      p:
        height: '300px'
      o:
        duration: 250
        easing: 'linear'

  onRemove: (event) ->
    $(event.target)
    .closest('.add-contact-info-b')
    .toggleClass('js-add-address-b')
    .toggleClass('js-remove-address-b')
    @iconType.set 'add_circle'
    $(@find('.icon-button')).css color: ''
    $(@find('.contact-info-inputs')).animate 'reverse'


  events: ->
    super.concat
      'click .js-add-address-b': @onAdd
      'click .js-remove-address-b': @onRemove
