DialogMixin = require '../../../mixins/dialog_mixin/dialog_mixin.coffee'
EMethods = require '../../../../api/collections/expenses/methods.coffee'
ExpenseModule = require '../../../../api/collections/expenses/expenses.coffee'
ErrorComponent = require '../../../mixins/error_mixin.coffee'



require './new.jade'

class ExpensesNew extends ErrorComponent
  @register 'expensesNew'

  mixins: -> [
    DialogMixin
  ]

  constructor: (args) ->
    super

  onCreated: ->
    super
    @totalPrice = new ReactiveVar('0.00')
    @schema = ExpenseModule.Expenses.simpleSchema()

  onRendered: ->
    super
    $('#right-paper-header-panel').addClass('touchScroll')

  currentList: (subscription)->
    return @callFirstWith(@, 'currentList', subscription);

  provider: ->
    provider = @currentList('providers')[0]
    return {} unless provider?
    provider

  unit: ->
    unit = @currentList('units')[0]
    return {} unless unit?
    @errorDict.set 'unit_id', false
    unit


  insert: (expense_doc) ->
    expense_doc.organization_id = FlowRouter.getParam('organization_id')
    EMethods.insert.call {expense_doc}, (err, res) =>
      console.log err
      if err?
        @errorDict.set ed.name, true for ed in err.details
        pins = @findAll('.pinput')
        $(pins).trigger('focusin')
        $(pins).trigger('focusout')

      $('.js-hide-new').trigger('click') unless err?

  onSubmit: (event) ->
    event.preventDefault()
    $form = $('.js-expenses-new-form')
    expense_doc =
      name: $form.find('[name=name]').val()
      price: Number $form.find('[name=price]').val()
      currency: $form.find('[name=currency]').val()
      description: $form.find('[name=description]').val()
      quantity: Number $form.find('[name=quantity]').val()
      provider_id: @provider()._id
      unit_id: @unit()._id
    @insert expense_doc

  onChange: (event) ->
    up = if @find('.unit-price .pinput')? then @find('.unit-price .pinput').value else 0
    q = if @find('.quantity .pinput')? then @find('.quantity .pinput').value else 0
    tot = up * q
    @totalPrice.set tot.toFixed(2)


  events: ->
    super.concat
      'input .js-value-changed': @onChange
      'submit .js-expenses-new-form': @onSubmit
      'click .js-submit-new-expense': @onSubmit
