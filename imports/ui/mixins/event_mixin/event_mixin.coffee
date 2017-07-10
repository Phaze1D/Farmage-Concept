
require './event_mixin.jade'

class EventMixin extends BlazeComponent

  onCreated: ->
    @eventTitle = new ReactiveVar('Change')
    @eventHidden = true
    @mainAmount = new ReactiveVar @mixinParent().initAmount

  minAmount: ->
    -@mixinParent().initAmount

  onToggleEvent: (event) ->
    unless $(event.currentTarget).attr('disabled')?
      if @eventHidden
        @showEvent()
      else
        @hideEvent()

  showEvent: ->
    @eventHidden = false
    @eventTitle.set 'Undo'
    @mainAmount.set @mixinParent().initAmount
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
    @mainAmount.set @mixinParent().initAmount
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
    am = @mixinParent().initAmount + Number input.val()
    @mainAmount.set am

  onFocusOut: (event) ->
    $(@find '.js-main-amount .pinput').trigger('focusin')
    $(@find '.js-main-amount .pinput').trigger('focusout')



  events: ->
    super.concat
      'click .js-event-b': @onToggleEvent
      'input .js-event-amount .pinput': @onAmountChange
      'focusout .js-event-amount .pinput': @onFocusOut

module.exports = EventMixin
