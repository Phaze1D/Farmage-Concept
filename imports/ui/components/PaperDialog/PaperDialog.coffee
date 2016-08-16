
require './PaperDialog.tpl.jade'

class PaperDialog extends BlazeComponent
  @register 'PaperDialog'


  onOpen: (event) ->
    if @data().callbacks? and @data().callbacks.showClick?
      @data().callbacks.showClick()

    $('#paper-drawer-main').css overflow: 'visible', 'z-index': 2
    skrim = $(@find('.skrim'))
    skrim.addClass('opened').removeClass('closed')
    skrim.velocity
      p:
        opacity: 1
      o:
        duration: 250
        complete: =>
          skrim.addClass('js-skrim')

  onSkrimClose: (event) ->
    if event.currentTarget is event.target
      @onClose(event)

  onClose: (event) ->
    skrim = $(@find('.skrim'))
    if @data().callbacks? and @data().callbacks.beforeHide?
      @data().callbacks.beforeHide()

    skrim.velocity
      p:
        opacity: 0
      o:
        duration: 250
        complete: =>
          if @data().callbacks? and @data().callbacks.hideClick?
            @data().callbacks.hideClick()
          skrim.addClass('closed').removeClass('opened')
          $('#paper-drawer-main').css overflow: 'hidden', 'z-index': 0
          skrim.removeClass('js-skrim')
          rphp = $('#right-paper-header-panel')
          rphp.scrollTop(rphp[0].scrollHeight)

  events: ->
    super.concat
      'click .js-open-dialog': @onOpen
      'click .js-close-dialog': @onClose
      'click .js-skrim': @onSkrimClose
