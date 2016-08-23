
require './event_mixin.jade'

class EventMixin extends BlazeComponent

  onCreated: ->
    @eventTitle = new ReactiveVar('Change')
    @eventHidden = true
    @mainAmount = new ReactiveVar(0)


  onToggleEvent: (event) ->
    unless $(event.currentTarget).attr('disabled')?
      if @eventHidden
        @showEvent()
      else
        @hideEvent()

  showEvent: ->
    @eventHidden = false
    @eventTitle.set 'Undo'
    @mainAmount.set 0
    ebox = $(@find '.event-box')
    ebox.css visibility: 'visible'
    ebox.velocity
      p:
        height: '115px'
      o:
        duration: 250
        easing: 'ease-in-out'
        complete: =>
          ebox.css height: ''
          ebox.velocity("scroll", { container: $('#right-paper-header-panel')});
    if @mixinParent().onShowEvent?
      @mixinParent().onShowEvent()

  hideEvent: ->
    @eventHidden = true
    @eventTitle.set 'Change'
    @mainAmount.set 0
    form = $('.js-form-event')
    form.find('[name=event_description]').val('')
    ebox = $(@find '.event-box')
    ebox.velocity
      p:
        height: '0px'
      o:
        duration: 250
        easing: 'ease-in-out'
        complete: ->
          ebox.css visibility: 'hidden'


  getMainAmount: ->
    @mainAmount.get()

  setMainAmount: (amount) ->
    @mainAmount.set amount

  isEventHidden: ->
    @eventHidden

  onAmountChange: (event) ->
    input = $(event.currentTarget)
    @mainAmount.set input.val()


  events: -> [
      'click .js-event-b': @onToggleEvent
      'input .js-event-amount .pinput': @onAmountChange
    ]


module.exports = EventMixin
