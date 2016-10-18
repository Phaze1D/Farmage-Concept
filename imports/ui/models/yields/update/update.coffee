DialogMixin = require '../../../mixins/dialog_mixin/dialog_mixin.coffee'
EventMixin = require '../../../mixins/event_mixin/event_mixin.coffee'
YMethods = require '../../../../api/collections/yields/methods.coffee'
YieldModule = require '../../../../api/collections/yields/yields.coffee'
EMethods = require '../../../../api/collections/events/methods.coffee'
ErrorComponent = require '../../../mixins/error_mixin.coffee'


require './update.jade'

class YieldsUpdate extends ErrorComponent
  @register 'yieldsUpdate'

  constructor: (args) ->
    super

  mixins: -> [ DialogMixin, EventMixin ]

  onCreated: ->
    super
    @initAmount = @yield().amount
    @schema = YieldModule.Yields.simpleSchema()

  onRendered: ->
    super
    $('#right-paper-header-panel').addClass('touchScroll')
    clist = @callFirstWith(@, 'clistsDict')
    _yield = YieldModule.Yields.findOne @data().update_id
    unit = _yield.unit().fetch()[0]
    ingredient = _yield.ingredient().fetch()[0]
    clist.set 'units', [unit]
    clist.set 'ingredients', [ingredient]

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
        min: -@yield().amount

      event_description:
        type: String
        label: 'description'
        max: 512
        decimal: false
        optional: true
    )

  yield: ->
    YieldModule.Yields.findOne @data().update_id

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

  update: (yield_doc, event_doc) ->
    amount = event_doc.amount
    yield_id = @data().update_id
    organization_id = FlowRouter.getParam('organization_id')
    event_doc.organization_id = organization_id

    YMethods.update.call {organization_id, yield_id, yield_doc}, (err, res) =>
      console.log err
      @errorDict.set ed.name, true for ed in err.details if err?
      @insertEvent(event_doc, yield_id) if amount isnt 0 && !err?
      $('.js-hide-new').trigger('click') if amount is 0 && !err?

  insertEvent: (event_doc, yield_id) =>
    event_doc.for_type = 'yield'
    event_doc.for_id = yield_id

    EMethods.userEvent.call {event_doc}, (err, res) =>
      console.log err
      $('.js-hide-new').trigger('click') unless err?


  onSubmit: (event) ->
    event.preventDefault()
    form = $('.js-yields-update-form')
    yield_doc =
      name: form.find('[name=name]').val()
      notes: form.find('[name=notes]').val()
      unit_id: @unit()._id

    event_doc =
      amount: Number form.find('[name=event_amount]').val()
      description: form.find('[name=event_description]').val()

    @update yield_doc, event_doc


  events: ->
    super.concat
      'submit .js-yields-update-form': @onSubmit
      'click .js-submit-update-yield': @onSubmit
