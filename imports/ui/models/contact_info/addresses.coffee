
require './addresses.jade'

class Address extends BlazeComponent
  @register 'address.add'

  constructor: (args) ->

  onCreated: ->
    super
    @iconType = new ReactiveVar 'add_circle'

  onAdd: (event) ->
    @iconType.set 'remove_circle'
    $(@find('.icon-button')).css color: '#FF3D00'
    $(@find('.address-inputs')).velocity
      p:
        height: '300px'
      o:
        duration: 250
        easing: 'linear'


  events: ->
    super.concat
      'click .js-add-address-b': @onAdd
