PMethods = require '../../../../api/collections/providers/methods.coffee'

require './new.jade'


class ProvidersNew extends BlazeComponent
  @register 'providersNew'

  constructor: (args) ->
    # body...

  onRendered: ->
    super
    $('#right-paper-header-panel').addClass('touchScroll')

  insert: (provider_doc) ->
    provider_doc.organization_id = FlowRouter.getParam('organization_id')
    PMethods.insert.call {provider_doc}, (err, res) ->
      console.log err
      $('.js-hide-new').trigger('click') unless err?


  onSubmit: (event) ->
    event.preventDefault()
    $form = $('.js-providers-new-form')

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

    provider_doc =
      first_name: $form.find('[name=first_name]').val()
      last_name: $form.find('[name=last_name]').val()
      company: $form.find('[name=company]').val()
      email: $form.find('[name=email]').val()
      notes: $form.find('[name=notes]').val()
      date_of_birth: $form.find('[name=date_of_birth]').val()
      addresses: addresses
      telephones: telephones

    @insert provider_doc


  events: ->
    super.concat
      'click .js-submit-new-provider': @onSubmit
      'submt .js-providers-new-form': @onSubmit
