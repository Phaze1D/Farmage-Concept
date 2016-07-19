require './PaperCard.tpl.jade'

class PaperCard extends BlazeComponent
  @register 'PaperCard'

  constructor: (args) ->

  onCreated: ->
    super
    @elevation = @data().elevation
    @expanded = false


  onRendered: ->
    super

  mouseDown: (event) ->
    pacard = $(event.target).closest('.paper-card')
    target = $(event.target)
    roffsetX = target.position().left + event.offsetX + parseInt target.css('margin-left')
    roffsetY = target.position().top  + event.offsetY + parseInt target.css('margin-top')
    pacard.find('.card-ripple:first').trigger('mousedown', [roffsetX, roffsetY])

  mouseUp: (event) ->
    pacard = $(event.target).closest('.paper-card')
    pacard.find('.card-ripple:first').trigger('mouseup')

  expand: (event) ->

    unless @expanded
      @expanded = true
      $wind = $(window)
      pacard = $(event.target).closest('.paper-card')
      top = pacard.offset().top - $wind.scrollTop();
      left = pacard.offset().left - $wind.scrollLeft();
      width = pacard.width()
      $('#paper-drawer-main').css overflow: 'hidden'


      pacard.css
        position: 'fixed'
        'z-index': 1
        top: "#{top}px"
        left: "#{left}px"
        width: "#{width}px"
        overflow: 'scroll'
      pacard.closest('paper-card').find('.card-ghost').css display: 'block'

      Meteor.setTimeout( ->
        pacard.addClass('card-expanded')
        pacard.velocity
          p:
            left: 0
            top: 0
            width: '100%'
            height: '100%'
          o:
            duration: 250
            easing: 'ease-in-out'
            complete: (elements) ->
              $('.paper-card').css visibility: 'hidden'
              pacard.css visibility: 'visible'
      , 300)


  shrink: (event) ->
    if @expanded
      $('.paper-card').css visibility: 'visible'
      $('#paper-drawer-main').css overflow: 'auto'
      pacard = $(event.target).closest('.paper-card')
      target = $(event.target)
      roffsetX = target.position().left + event.offsetX + parseInt target.css('margin-left')
      roffsetY = target.position().top  + event.offsetY + parseInt target.css('margin-top')
      pacard.find('.card-ripple:first').trigger('click', [roffsetX, roffsetY])
      Meteor.setTimeout( =>
        pacard.removeClass('card-expanded')
        pacard.velocity "reverse",
          complete: (elements) =>
            @expanded = false
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
