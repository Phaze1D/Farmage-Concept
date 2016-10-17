DialogMixin = require '../../../mixins/dialog_mixin/dialog_mixin.coffee'
EventMixin = require '../../../mixins/event_mixin/event_mixin.coffee'
UMethods = require '../../../../api/collections/units/methods.coffee'
EMethods = require '../../../../api/collections/events/methods.coffee'
UnitModule = require '../../../../api/collections/units/units.coffee'




require './new.jade'

class UnitsNew extends BlazeComponent
  @register 'unitsNew'

  constructor: (args) ->
    super
    @initAmount = 0

  mixins: -> [ DialogMixin, EventMixin ]


  onCreated: ->
    super
    @schema = UnitModule.Units.simpleSchema()

  onRendered: ->
    super
    $('#right-paper-header-panel').addClass('touchScroll')

  eventSchema: ->
    new SimpleSchema(
      amount:
        type: Number
        label: 'amount'
        decimal: false
        min: 0

      event_amount:
        type: Number
        label: 'amount'
        decimal: false
        optional: true
        min: 0

      event_description:
        type: String
        label: 'description'
        max: 512
        decimal: false
        optional: true
    )


  currentList: (subscription)->
    return @callFirstWith(@, 'currentList', subscription);

  parentUnit: ->
    punit = @currentList('units')[0]
    return {} unless punit?
    punit

  convert: (value) ->
    return true if value is 'on'
    return false if value is 'off'

  insert: (unit_doc, event_doc) ->
    amount = event_doc.amount
    unit_doc.amount = 0
    unit_doc.organization_id = FlowRouter.getParam('organization_id')
    event_doc.organization_id = unit_doc.organization_id

    UMethods.insert.call {unit_doc}, (err, res) =>
      console.log err
      @insertEvent(event_doc, res) if amount > 0 && res?
      $('.js-hide-new').trigger('click') if amount <= 0 && !err?


  insertEvent: (event_doc, unit_id) =>
    event_doc.for_type = 'unit'
    event_doc.for_id = unit_id

    EMethods.userEvent.call {event_doc}, (err, res) =>
      console.log err
      $('.js-hide-new').trigger('click') unless err?


  onSubmit: (event) ->
    event.preventDefault()
    form = $('.js-units-new-form')
    unit_doc =
      name: form.find('[name=name]').val()
      description: form.find('[name=description]').val()
      amount: Number form.find('[name=event_amount]').val()
      tracking: @convert form.find('.js-toggle-box[track]').find('.js-toggle').attr('toggled')
      unit_id: @parentUnit()._id

    event_doc =
      amount: Number form.find('[name=event_amount]').val()
      description: form.find('[name=event_description]').val()

    @insert unit_doc, event_doc


  onToggleGrid: (event) ->
    tar = $(event.currentTarget)
    tar.find('.js-toggle').trigger('click')
    if tar.find('.js-toggle').attr('toggled') is 'on'
      @onToggleOnCallback()
    else
      @onToggleOffCallback()



  onToggleOnCallback: =>
    ed = $(@find '.event-div')
    ed.velocity
      p:
        height: '68px'
      o:
        duration: 250
        easing: 'ease-in-out'
        complete: ->
          ed.css height: 'auto'

  onToggleOffCallback: =>
    @callFirstWith(@, 'hideEvent');
    $(@find '.event-div').velocity
      p:
        height: '0'
      o:
        duration: 250
        easing: 'ease-in-out'


  toggleCallbacks: ->
    ret =
      onToggleOn: @onToggleOnCallback
      onToggleOff: @onToggleOffCallback

  events: ->
    super.concat
      'click .js-toggle-grid': @onToggleGrid
      'submit .js-units-new-form': @onSubmit
      'click .js-submit-new-unit': @onSubmit
