EventMixin = require '../../../mixins/event_mixin/event_mixin.coffee'
DialogMixin = require '../../../mixins/dialog_mixin/dialog_mixin.coffee'
UMethods = require '../../../../api/collections/units/methods.coffee'
EMethods = require '../../../../api/collections/events/methods.coffee'



require './new.jade'

class UnitsNew extends BlazeComponent
  @register 'unitsNew'

  mixins: -> [
    EventMixin, DialogMixin
  ]


  onCreated: ->
    super


  currentList: (subscription)->
    return @callFirstWith(@, 'currentList', subscription);

  parentUnit: ->
    punit = @currentList('units')[0]
    return {} unless punit?
    punit

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
      unit_id: @parentUnit()._id

    event_doc =
      amount: Number form.find('[name=event_amount]').val()
      description: form.find('[name=event_description]').val()

    @insert unit_doc, event_doc


  events: ->
    super.concat
      'submit .js-units-new-form': @onSubmit
      'click .js-submit-new-unit': @onSubmit
