DialogMixin = require '../../../mixins/dialog_mixin/dialog_mixin.coffee'
EMethods = require '../../../../api/collections/expenses/methods.coffee'

require './new.jade'

class ExpensesNew extends BlazeComponent
  @register 'expensesNew'

  mixins: -> [
    DialogMixin
  ]

  onCreated: ->
    super

  currentList: (subscription)->
    return @callFirstWith(@, 'currentList', subscription);

  provider: ->
    provider = @currentList('providers')[0]
    return {}unless provider?
    provider

  unit: ->
    unit = @currentList('units')[0]
    return {} unless unit?
    unit

  insert: (expense_doc) ->
    expense_doc.organization_id = FlowRouter.getParam('organization_id')
    EMethods.insert.call {expense_doc}, (err, res) ->
      console.log err
      $('.js-hide-new').trigger('click') unless err?

  onSubmit: (event) ->
    event.preventDefault()
    $form = $('.js-expenses-new-form')
    expense_doc =
      name: $form.find('[name=name]').val()
      price: $form.find('[name=price]').val()
      currency: $form.find('[name=currency]').val()
      description: $form.find('[name=description]').val()
      quantity: $form.find('[name=quantity]').val()
      receipt_id: $form.find('[name=receipt_id]').val()
      provider_id: @provider()._id
      unit_id: @unit()._id
    @insert expense_doc


  events: ->
    super.concat
      'submit .js-expenses-new-form': @onSubmit
      'click .js-submit-new-expense': @onSubmit
