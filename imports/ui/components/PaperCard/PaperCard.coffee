require './PaperCard.tpl.jade'

class PaperCard extends BlazeComponent
  @register 'PaperCard'

  constructor: (args) ->

  onCreated: ->
    super
    @expanded = false
    @borderR = 0
    @data().rippleFill = 'black' unless @data().rippleFill?


  onRendered: ->
    super


  mouseDown: (event) ->
    tar = $(event.target)
    tar
    .closest('.paper-card')
    .find('.card-ripple:first')
    .trigger 'mousedown',
      [
        ( tar.position().left + event.offsetX + parseInt tar.css('margin-left') ),
        ( tar.position().top  + event.offsetY + parseInt tar.css('margin-top') )
      ]


  mouseUp: (event) ->
    $(event.target)
    .closest('.paper-card')
    .find('.card-ripple:first')
    .trigger('mouseup')


  expand: (event) ->

    unless @expanded
      tar = $(event.target)
      ghost = $(@find('.card-ghost'))
      ghost.css height: $(@find('.paper-card')).innerHeight()
      @expanded = true
      pacard = tar.closest('.paper-card')
      headerPanel = tar.closest('.paper-header-panel')
      headerPanel.css overflow: 'hidden'
      @borderR = pacard.css('border-radius')
      pacard.css
        'border-radius': 0
        overflow: 'hidden'
        position: 'absolute'
        'z-index': 2
        top: "#{pacard.position().top + headerPanel.scrollTop()}px"
        left: "#{pacard.position().left}px"
        width: "#{pacard.innerWidth()}px"
        height: "#{pacard.innerHeight()}px"

      ghost.css display: 'block'

      Meteor.setTimeout( ->
        # @data().callbacks.onExpandCallback()
        pacard.css 'box-shadow': 'none'
        pacard.velocity
          p:
            left: 0
            top: headerPanel.scrollTop()
            width: '100%'
            height: '100vh'
          o:
            duration: 250
            easing: 'ease-in-out'
            complete: (elements) =>
              $('.paper-card').css display: 'none'
              pacard.css display: 'block'
      , 250)





  shrink: (event) ->
    if @expanded
      tar = $(event.target)
      @expanded = false
      $('.paper-card').css display: ''
      headerPanel = tar.closest('.paper-header-panel')
      headerPanel.css overflow: ''
      pacard = tar.closest('.paper-card')

      pacard.find('.card-ripple:first').trigger 'click', [
        tar.position().left + event.offsetX + parseInt tar.css('margin-left'),
        tar.position().top  + event.offsetY + parseInt tar.css('margin-top')
      ]


      ghost = $(@find('.card-ghost'))
      pacard.velocity
        p:
          left: ghost.position().left
          top: ghost.position().top + headerPanel.scrollTop()
          width: ghost.innerWidth() + 'px'
          height: ghost.innerHeight() + 'px'
        o:
          duration: 250
          delay: 250
          complete: =>
            pacard.css
              position: ''
              'z-index': ''
              top: ""
              left: ""
              width: ""
              overflow: ''
              height: ''
              'box-shadow': ''
              'border-radius': ''
            ghost.css display: 'none'




  events: ->
    super.concat
      'click .card-expand-action': @expand
      'click .card-shrink-action': @shrink
      'mousedown .card-expand-action, mousedown .card-shrink-action': @mouseDown
      'mouseup .card-expand-action, mouseup .card-shrink-action': @mouseUp
      # 'mouseout .card-expand-action, mouseout .card-shrink-action': @mouseUp
