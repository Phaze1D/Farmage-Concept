

class CardEvents extends BlazeComponent

  constructor: (args) ->
    @show = new ReactiveVar(false)

  onExpand: (event) ->
    @show.set(true)
    $(@findAll '.chart-div').css display: 'none'
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
          $(@findAll '.chart-div').css display: ''
          $(@find '.show').css display: 'none'
          @show.set(false)

  events: ->
    super.concat
      'click .card-expand-action': @onExpand
      'click .card-shrink-action': @onShrink


module.exports = CardEvents
