

require './telephones.jade'


class TelephoneAdd extends BlazeComponent
  @register 'telephone.add'

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
    .toggleClass('js-add-telephone-b')
    .toggleClass('js-remove-telephone-b')
    $(@find('.icon-button')).css color: '#FF3D00'
    $(@find('.contact-info-inputs')).animate
      p:
        height: '60px'
      o:
        duration: 250
        easing: 'linear'

  onRemove: (event) ->
    $(event.target)
    .closest('.add-contact-info-b')
    .toggleClass('js-add-telephone-b')
    .toggleClass('js-remove-telephone-b')
    @iconType.set 'add_circle'
    $(@find('.icon-button')).css color: ''
    $(@find('.contact-info-inputs')).animate 'reverse'


  events: ->
    super.concat
      'click .js-add-telephone-b': @onAdd
      'click .js-remove-telephone-b': @onRemove
