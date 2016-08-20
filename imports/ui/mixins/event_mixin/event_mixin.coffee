
require './event_mixin.jade'

class EventMixin extends BlazeComponent

  onCreated: ->
    @eventTitle = new ReactiveVar('Change')


  onToggleEvent: (event) ->
    console.log $(event.currentTarget).attr('disabled')
    unless $(event.currentTarget).attr('disabled')?
      if @eventTitle.get() is 'Undo'
        @hideEvent()
      else
        @showEvent()

  showEvent: ->
    @eventTitle.set 'Undo'
    ebox = $(@find '.event-box')
    ebox.css visibility: 'visible'
    ebox.velocity
      p:
        height: '115px'
      o:
        duration: 250
        easing: 'ease-in-out'
        complete: ->
          ebox.css height: ''
          ebox.velocity("scroll", { container: $('#right-paper-header-panel')});

  hideEvent: ->
    @eventTitle.set 'Change'
    form = $('.js-form-event')
    form.find('[name=amount]').val(0)
    form.find('[name=event_amount]').val(0)
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




  onAmountChange: (event) ->
    input = $(event.currentTarget)
    input.closest('.js-form-event').find('[name=amount]').val(input.val())


  events: -> [
      'click .js-event-b': @onToggleEvent
      'input .js-event-amount .pinput': @onAmountChange
    ]


module.exports = EventMixin
