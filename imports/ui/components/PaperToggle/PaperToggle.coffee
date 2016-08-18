require './PaperToggle.tpl.jade'

class PaperToggle extends BlazeComponent
  @register 'PaperToggle'

  constructor: (args) ->
    # body...

  onToggle: (event) ->
    event.stopImmediatePropagation()
    qcircle = $(@find '.circle')
    backBar = $(@find '.back-bar')
    if $(event.currentTarget).attr('toggled') is 'on'
      $(event.currentTarget).attr('toggled', 'off')
      @toggleOff(qcircle, backBar)
    else
      $(event.currentTarget).attr('toggled', 'on')
      @toggleOn(qcircle, backBar)


  toggleOn: (qcircle, backBar) ->
    gird = qcircle.closest('.js-toggle-box')
    gird.find('.ou-label').css color: 'darkblue'
    qcircle.velocity
      p:
        left: '100%'
        'margin-left': '-20px'
        backgroundColor: '#00008b'
      o:
        duration: 250
        easing: 'ease-in-out'

    backBar.velocity
      p:
        backgroundColor: '#00008b'
        opacity: 0.5
      o:
        duration: 250
        easing: 'ease-in-out'

  toggleOff: (qcircle, backBar) ->
    gird = qcircle.closest('.js-toggle-box')
    gird.find('.ou-label').css color: ''
    qcircle.velocity
      p:
        left: '0'
        'margin-left': '0'
        backgroundColor: '#fff'
      o:
        duration: 250
        easing: 'ease-in-out'

    backBar.velocity
      p:
        backgroundColor: '#bdbdbd'
        opacity: 1
      o:
        duration: 250
        easing: 'ease-in-out'



  events: ->
    super.concat
      'click .js-toggle': @onToggle
