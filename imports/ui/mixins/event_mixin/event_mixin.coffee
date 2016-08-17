
require './event_mixin.jade'

class EventMixin extends BlazeComponent

  onCreated: ->
    @eventTitle = new ReactiveVar('Change')


  onToggleEvent: (event) ->
    if @eventTitle.get() is 'Undo'
      @hideEvent()
    else
      @showEvent()

  showEvent: ->
    @eventTitle.set 'Undo'
    ebox = $(@find '.event-box')
    ebox.velocity
      p:
        height: '135px'
      o:
        duration: 250
        easing: 'ease-in-out'
        complete: ->
          ebox.css(height: '')

  hideEvent: ->
    @eventTitle.set 'Change'
    form = $('.js-form-event')
    form.find('[name=amount]').val('0')
    form.find('[name=event_amount]').val('0')
    $(@find '.event-box').velocity
      p:
        height: '0px'
      o:
        duration: 250
        easing: 'ease-in-out'


  onAmountChange: (event) ->
    input = $(event.currentTarget)
    input.closest('.js-form-event').find('[name=amount]').val(input.val())


  events: -> [
      'click .js-event-b': @onToggleEvent
      'input .js-event-amount .pinput': @onAmountChange
    ]


module.exports = EventMixin
