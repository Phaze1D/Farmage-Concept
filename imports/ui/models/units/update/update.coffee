EventMixin = require '../../../mixins/event_mixin/event_mixin.coffee'
DialogMixin = require '../../../mixins/dialog_mixin/dialog_mixin.coffee'
UMethods = require '../../../../api/collections/units/methods.coffee'
UnitModule = require '../../../../api/collections/units/units.coffee'
EMethods = require '../../../../api/collections/events/methods.coffee'

require './update.jade'

class UnitsUpdate extends BlazeComponent
  @register 'unitsUpdate'

  constructor: (args) ->
    super

  mixins: -> [ DialogMixin, EventMixin ]

  onCreated: ->
    super
    @initAmount = @unit().amount

  onRendered: ->
    super
    $('#right-paper-header-panel').addClass('touchScroll')
    clist = @callFirstWith(@, 'clistsDict')
    unit = UnitModule.Units.findOne @data().parent_id
    clist.set 'units', [unit] if unit?


  unit: ->
    UnitModule.Units.findOne @data().update_id

  tracking: ->
    if @unit().tracking
      'on'
    else
      'off'

  trackAttr: ->
    unless @unit().tracking
      'height: 0px'

  currentList: (subscription)->
    return @callFirstWith(@, 'currentList', subscription);

  parentUnit: ->
    punit = @currentList('units')[0]
    return {} unless punit?
    punit

  convert: (value) ->
    return true if value is 'on'
    return false if value is 'off'

  update: (unit_doc, event_doc) ->
    amount = event_doc.amount
    unit_doc.amount = 0
    unit_id = @data().update_id
    organization_id = FlowRouter.getParam('organization_id')
    event_doc.organization_id = organization_id

    UMethods.update.call {organization_id, unit_id ,unit_doc}, (err, res) =>
      console.log err
      @insertEvent(event_doc, unit_id) if amount isnt 0 && !err?
      $('.js-hide-new').trigger('click') if amount is 0 && !err?


  insertEvent: (event_doc, unit_id) =>
    event_doc.for_type = 'unit'
    event_doc.for_id = unit_id

    EMethods.userEvent.call {event_doc}, (err, res) =>
      console.log err
      $('.js-hide-new').trigger('click') unless err?


  onSubmit: (event) ->
    event.preventDefault()
    form = $('.js-units-update-form')
    unit_doc =
      name: form.find('[name=name]').val()
      description: form.find('[name=description]').val()
      tracking: @convert form.find('.js-toggle-box[track]').find('.js-toggle').attr('toggled')
      unit_id: @parentUnit()._id

    event_doc =
      amount: Number form.find('[name=event_amount]').val()
      description: form.find('[name=event_description]').val()

    @update unit_doc, event_doc


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
      'submit .js-units-update-form': @onSubmit
      'click .js-submit-update-unit': @onSubmit
