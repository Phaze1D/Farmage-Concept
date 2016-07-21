require './PaperCard.tpl.jade'

class PaperCard extends BlazeComponent
  @register 'PaperCard'

  constructor: (args) ->

  onCreated: ->
    super
    @expanded = false


  onRendered: ->
    super


  mouseDown: (event) ->
    $(event.target)
    .closest('.paper-card')
    .find('.card-ripple:first')
    .trigger 'mousedown',
      [
        ( $(event.target).position().left + event.offsetX + parseInt $(event.target).css('margin-left') ),
        ( $(event.target).position().top  + event.offsetY + parseInt $(event.target).css('margin-top') )
      ]


  mouseUp: (event) ->
    $(event.target)
    .closest('.paper-card')
    .find('.card-ripple:first')
    .trigger('mouseup')


  expand: (event) ->

    unless @expanded
      $(@find('.card-ghost')).css height: $(@find('.paper-card')).height()
      @expanded = true
      pacard = $(event.target).closest('.paper-card')
      $('#paper-drawer-main').css overflow: 'hidden'

      pacard.css
        position: 'absolute'
        'z-index': 1
        top: "#{pacard.position().top}px"
        left: "#{pacard.position().left}px"
        width: "#{pacard.width()}px"
        'overflow-y': 'scroll'
      pacard.closest('paper-card').find('.card-ghost').css display: 'block'

      Meteor.setTimeout( ->
        pacard.velocity
          p:
            left: 0
            top: $('#paper-drawer-main').scrollTop()
            width: '100%'
            height: '100vh'
            'border-radius': 0
          o:
            duration: 250
            easing: 'ease-in-out'
            complete: (elements) ->
              $('.paper-card').css visibility: 'hidden'
              pacard.css visibility: 'visible'
      , 250)


  shrink: (event) ->
    if @expanded
      @expanded = false
      $('.paper-card').css visibility: 'visible'
      $('#paper-drawer-main').css overflow: 'auto'
      pacard = $(event.target).closest('.paper-card')

      pacard.find('.card-ripple:first').trigger 'click', [
        $(event.target).position().left + event.offsetX + parseInt $(event.target).css('margin-left'),
        $(event.target).position().top  + event.offsetY + parseInt $(event.target).css('margin-top')
      ]


      Meteor.setTimeout( =>
        pacard.velocity "reverse",
          complete: (elements) =>
            pacard.closest('paper-card').find('.card-ghost').css display: 'none'
            pacard.css
              position: ''
              'z-index': ''
              top: ""
              left: ""
              width: ""
              overflow: ''
              height: ''
      , 250)



  events: ->
    super.concat
      'click .card-expand-action': @expand
      'click .card-shrink-action': @shrink
      'mousedown .card-expand-action, mousedown .card-shrink-action': @mouseDown
      'mouseup .card-expand-action, mouseup .card-shrink-action': @mouseUp
      'mouseout .card-expand-action, mouseout .card-shrink-action': @mouseUp
