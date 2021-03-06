DialogMixin = require '../../../mixins/dialog_mixin/dialog_mixin.coffee'
EventMixin = require '../../../mixins/event_mixin/event_mixin.coffee'
ErrorComponent = require '../../../mixins/error_mixin.coffee'
YMethods = require '../../../../api/collections/yields/methods.coffee'
YieldModule = require '../../../../api/collections/yields/yields.coffee'
EMethods = require '../../../../api/collections/events/methods.coffee'


require './new.jade'

class YieldsNew extends ErrorComponent
  @register 'yieldsNew'

  constructor: (args) ->
    super
    @initAmount = 0

  mixins: -> [ DialogMixin, EventMixin]

  onCreated: ->
    super
    @schema = YieldModule.Yields.simpleSchema()


  onRendered: ->
    super
    $('#right-paper-header-panel').addClass('touchScroll')

  eventSchema: ->
    new SimpleSchema(
      amount:
        type: Number
        label: 'amount'
        decimal: true
        min: 0

      event_amount:
        type: Number
        label: 'amount'
        decimal: true
        optional: true
        min: 0

      event_description:
        type: String
        label: 'description'
        max: 512
        optional: true
    )

  currentList: (subscription)->
    return @callFirstWith(@, 'currentList', subscription);

  ingredient: ->
    ingredient = @currentList('ingredients')[0]
    return {} unless ingredient?
    @errorDict.set 'ingredient_id', false
    ingredient

  unit: ->
    unit = @currentList('units')[0]
    return {} unless unit?
    @errorDict.set 'unit_id', false
    unit

  insert: (yield_doc, event_doc) ->
    amount = event_doc.amount
    yield_doc.amount = 0
    yield_doc.organization_id = FlowRouter.getParam('organization_id')
    event_doc.organization_id = yield_doc.organization_id

    YMethods.insert.call {yield_doc}, (err, res) =>
      console.log err
      if err?
        @errorDict.set ed.name, true for ed in err.details
        pins = @findAll('.pinput')
        $(pins).trigger('focusin')
        $(pins).trigger('focusout')
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
