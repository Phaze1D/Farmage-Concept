CMethods = require '../../../../api/collections/customers/methods.coffee'
CustomerModule = require '../../../../api/collections/customers/customers.coffee'


require './update.jade'

class CustomersUpdate extends BlazeComponent
  @register 'customersUpdate'

  constructor: (args) ->
    # body...

  onCreated: ->
    super

  onRendered: ->
    super
    $('#right-paper-header-panel').addClass('touchScroll')

  customer: ->
    CustomerModule.Customers.findOne(@data().update_id)

  update: (customer_doc) ->
    organization_id = FlowRouter.getParam 'organization_id'
    customer_id = @data().update_id
    CMethods.update.call {organization_id, customer_id, customer_doc}, (err, res) =>
      console.log err
      $('.js-hide-new').trigger('click') unless err?



  onSubmit: (event) ->
    event.preventDefault()
    $form = $('.js-customers-update-form')

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

    email = $form.find('[name=email]').val()
    customer_doc =
      first_name: $form.find('[name=first_name]').val()
      last_name: $form.find('[name=last_name]').val()
      company: $form.find('[name=company]').val()
      email: if email.length is 0 then null else email
      notes: $form.find('[name=notes]').val()
      date_of_birth: $form.find('[name=date_of_birth]').val()
      addresses: addresses
      telephones: telephones

    @update customer_doc


  events: ->
    super.concat
      'click .js-submit-update-customer': @onSubmit
      'submt .js-customers-update-form': @onSubmit
