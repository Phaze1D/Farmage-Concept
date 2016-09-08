require './card.jade'

class UnitCard extends BlazeComponent
  @register 'UnitCard'

  constructor: (args) ->
    super

  onCreated: ->
    super
    @eTitle = new ReactiveVar('Change')

  onChangeClick: (event) ->
    tar = $(@find '.hidden-event')
    console.log tar.attr('show')
    if tar.attr('show') is 'no'
      @eTitle.set('Cancel')
      tar.attr('show', 'yes')
      tar.velocity
        p:
          height: 130
        o:
          duration: 250
          easing: 'ease-in-out'
          complete: ->
            tar.css height: 'auto'
    else
      @eTitle.set('Change')
      tar.attr('show', 'no')
      tar.velocity
        p:
          height: 0
        o:
          duration: 250
          easing: 'ease-in-out'




  events: ->
    super.concat
      'focusin .js-change': @onChangeClick
