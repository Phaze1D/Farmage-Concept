EventMixin = require '../../../mixins/event_mixin/event_mixin.coffee'
DialogMixin = require '../../../mixins/dialog_mixin/dialog_mixin.coffee'
YMethods = require '../../../../api/collections/yields/methods.coffee'
EMethods = require '../../../../api/collections/events/methods.coffee'


require './new.jade'

class YieldsNew extends BlazeComponent
  @register 'yieldsNew'

  constructor: (args) ->

  mixins: -> [
    EventMixin, DialogMixin
  ]

  currentList: (subscription)->
    return @callFirstWith(@, 'currentList', subscription);

  ingredient: ->
    ingredient = @currentList('ingredients')[0]
    return {} unless ingredient?
    ingredient

  unit: ->
    unit = @currentList('units')[0]
    return {} unless unit?
    unit

  insert: (yield_doc, event_doc) ->
    amount = event_doc.amount
    yield_doc.amount = 0
    yield_doc.organization_id = FlowRouter.getParam('organization_id')
    event_doc.organization_id = yield_doc.organization_id

    YMethods.insert.call {yield_doc}, (err, res) =>
      console.log err
      @insertEvent(event_doc, res) if amount > 0 && res?
      $('.js-hide-new').trigger('click') if amount <= 0 && !err?

  insertEvent: (event_doc, yield_id) =>
    event_doc.for_type = 'yield'
    event_doc.for_id = yield_id

    EMethods.userEvent.call {event_doc}, (err, res) =>
      console.log err
      $('.js-hide-new').trigger('click') unless err?


  onSubmit: (event) ->
    event.preventDefault()
    form = $('.js-yields-new-form')
    yield_doc =
      name: form.find('[name=name]').val()
      amount: 0
      notes: form.find('[name=notes]').val()
      ingredient_id: @ingredient()._id
      unit_id: @unit()._id

    event_doc =
      amount: Number form.find('[name=event_amount]').val()
      description: form.find('[name=event_description]').val()

    @insert yield_doc, event_doc


  events: ->
    super.concat
      'submit .js-yields-new-form': @onSubmit
      'click .js-submit-new-yield': @onSubmit
