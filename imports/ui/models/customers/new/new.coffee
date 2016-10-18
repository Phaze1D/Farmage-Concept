CMethods = require '../../../../api/collections/customers/methods.coffee'
CustomerModule = require '../../../../api/collections/customers/customers.coffee'


require './new.jade'


class CustomersNew extends BlazeComponent
  @register 'customersNew'

  constructor: (args) ->
    # body...

  onCreated: ->
    super
    @schema = CustomerModule.Customers.simpleSchema()


  onRendered: ->
    super
    $('#right-paper-header-panel').addClass('touchScroll')

  insert: (customer_doc) ->
    customer_doc.organization_id = FlowRouter.getParam('organization_id')
    CMethods.insert.call {customer_doc}, (err, res) =>
      console.log err
      if err?
        pins = @findAll('.pinput')
        $(pins).trigger('focusin')
        $(pins).trigger('focusout')

      $('.js-hide-new').trigger('click') unless err?


  onSubmit: (event) ->
    event.preventDefault()
    $form = $('.js-customers-new-form')

    addresses =[]
    $form.find('.address-form').each ->
      addresses.push
        name: $(@).find('[name=address_name]').val()
        street: $(@).find('[name=street]').val()
        street2: $(@).find('[name=street2]').val()
        city: $(@).find('[name=city]').val()
        state: $(@).find('[name=state]').val()
        zip_code: $(@).find('[name=zip_code]').val()
        country: $(@).find('[name=country]').val()

    telephones = []
    $form.find('.telephone-form').each ->
      telephones.push
        name: $(@).find('[name=telephone_name]').val()
        number: $(@).find('[name=number]').val()

    date =  new Date $form.find('[name=date_of_birth]').val()
    customer_doc =
      first_name: $form.find('[name=first_name]').val()
      last_name: $form.find('[name=last_name]').val()
      company: $form.find('[name=company]').val()
      email: $form.find('[name=email]').val()
      notes: $form.find('[name=notes]').val()
      date_of_birth: if isNaN(date.getMonth()) then null else date
      addresses: addresses
      telephones: telephones

    @insert customer_doc


  events: ->
    super.concat
      'click .js-submit-new-customer': @onSubmit
      'submt .js-customers-new-form': @onSubmit
