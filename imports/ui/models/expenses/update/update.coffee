ExpenseModule = require '../../../../api/collections/expenses/expenses.coffee'
ProviderModule = require '../../../../api/collections/providers/providers.coffee'
UnitModule = require '../../../../api/collections/units/units.coffee'

EMethods = require '../../../../api/collections/expenses/methods.coffee'
DialogMixin = require '../../../mixins/dialog_mixin/dialog_mixin.coffee'


require './update.jade'

class ExpensesUpdate extends BlazeComponent
  @register 'expensesUpdate'

  mixins: -> [
    DialogMixin
  ]


  onCreated: ->
    super
    @totalPrice = new ReactiveVar()

  onRendered: ->
    super
    $('#right-paper-header-panel').addClass('touchScroll')
    clist = @callFirstWith(@, 'clistsDict')
    provider = ProviderModule.Providers.findOne @data().provider_id
    unit = UnitModule.Units.findOne @data().unit_id
    clist.set 'providers', [provider]
    clist.set 'units', [unit]


  expense: ->
    ExpenseModule.Expenses.findOne @data().update_id

  currentList: (subscription)->
    return @callFirstWith(@, 'currentList', subscription);

  provider: ->
    provider = @currentList('providers')[0]
    return {} unless provider?
    provider

  unit: ->
    unit = @currentList('units')[0]
    return {} unless unit?
    unit


  update: (expense_doc) ->
    organization_id = FlowRouter.getParam('organization_id')
    expense_id = @data().update_id
    EMethods.update.call {organization_id, expense_id, expense_doc}, (err, res) ->
      console.log err
      $('.js-hide-new').trigger('click') unless err?


  onSubmit: (event) ->
    event.preventDefault()
    $form = $('.js-expenses-update-form')
    expense_doc =
      name: $form.find('[name=name]').val()
      price: $form.find('[name=price]').val()
      currency: $form.find('[name=currency]').val()
      description: $form.find('[name=description]').val()
      quantity: $form.find('[name=quantity]').val()
      receipt_id: $form.find('[name=receipt_id]').val()
      provider_id: @provider()._id
      unit_id: @unit()._id
    @update expense_doc

  onChange: (event) ->
    expense = @expense()
    up = if @find('.unit-price .pinput')? then @find('.unit-price .pinput').value else expense.price
    q = if @find('.quantity .pinput')? then @find('.quantity .pinput').value else expense.quantity
    tot = up * q
    @totalPrice.set tot.toFixed(2)


  events: ->
    super.concat
      'input .js-value-changed': @onChange
      'submit .js-expenses-update-form': @onSubmit
      'click .js-submit-update-expense': @onSubmit
