require './PaperCard.tpl.jade'

class PaperCard extends BlazeComponent
  @register 'PaperCard'

  constructor: (args) ->

  onCreated: ->
    super
    @elevation = @data().elevation

  onRendered: ->
    super


  expand: (event) ->
    $wind = $(window)
    console.log 'ecpan'
    pacard = $(event.target).closest('.paper-card')
    top = pacard.offset().top - $wind.scrollTop();
    left = pacard.offset().left - $wind.scrollLeft();
    width = pacard.width()

    pacard.css
      position: 'fixed'
      'z-index': 1
      top: "#{top}px"
      left: "#{left}px"
      width: "#{width}px"
      overflow: 'scroll'

    Meteor.setTimeout( ->
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
            $('.paper-card').css display: 'none'
            pacard.css display: 'block'
            pacard.addClass('card-expanded')
    , 250)




  events: ->
    super.concat
      'click .paper-card': @expand
