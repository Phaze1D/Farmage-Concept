ProviderModule = require '../../../../api/collections/providers/providers.coffee'
PMethods = require '../../../../api/collections/providers/methods.coffee'

require './update.jade'

class ProvidersUpdate extends BlazeComponent
  @register 'providersUpdate'

  constructor: (args) ->

  onRendered: ->
    super
    $('#right-paper-header-panel').addClass('touchScroll')

  provider: ->
    ProviderModule.Providers.findOne(@data().update_id)

  update: (provider_doc) ->
    organization_id = FlowRouter.getParam 'organization_id'
    provider_id = @data().update_id
    PMethods.update.call {organization_id, provider_id, provider_doc}, (err, res) =>
      console.log err
      $('.js-hide-new').trigger('click') unless err?



  onSubmit: (event) ->
    event.preventDefault()
    $form = $('.js-providers-update-form')

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
    provider_doc =
      first_name: $form.find('[name=first_name]').val()
      last_name: $form.find('[name=last_name]').val()
      company: $form.find('[name=company]').val()
      email: if email.length is 0 then null else email
      notes: $form.find('[name=notes]').val()
      date_of_birth: $form.find('[name=date_of_birth]').val()
      addresses: addresses
      telephones: telephones

    @update provider_doc


  events: ->
    super.concat
      'click .js-submit-update-provider': @onSubmit
      'submt .js-providers-update-form': @onSubmit
