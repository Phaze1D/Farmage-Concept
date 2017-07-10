OMethods = require '../../../../api/collections/organizations/methods.coffee'
OrganizationModule = require '../../../../api/collections/organizations/organizations.coffee'

require './update.jade'


class OrganizationsUpdate extends BlazeComponent
  @register 'organizationsUpdate'

  constructor: (args) ->
    # body...

  onCreated: ->
    super
    @schema = OrganizationModule.Organizations.simpleSchema()

  onRendered: ->
    super
    $('#right-paper-header-panel').addClass('touchScroll')

  organization: ->
    OrganizationModule.Organizations.findOne @data().update_id

  update: (organization_doc) ->
    organization_id = @data().update_id
    OMethods.update.call {organization_id, organization_doc}, (err, res) =>
      if err?
        pins = @findAll('.pinput')
        $(pins).trigger('focusin')
        $(pins).trigger('focusout')
      console.log err
      $('.js-hide-new').trigger('click') unless err


  onSubmit: (event) ->
    event.preventDefault()
    $form = $('.js-organization-update-form')

    adds =[]
    $form.find('.address-form').each ->
      adds.push
        name: $(@).find('[name=address_name]').val()
        street: $(@).find('[name=street]').val()
        street2: $(@).find('[name=street2]').val()
        city: $(@).find('[name=city]').val()
        state: $(@).find('[name=state]').val()
        zip_code: $(@).find('[name=zip_code]').val()
        country: $(@).find('[name=country]').val()

    teles = []
    $form.find('.telephone-form').each ->
      teles.push
        name: $(@).find('[name=telephone_name]').val()
        number: $(@).find('[name=number]').val()

    organization_doc =
      name: $form.find('[name=name]').val()
      email: $form.find('[name=email]').val()
      addresses: adds
      telephones: teles

    @update organization_doc


  events: ->
    super.concat
      'submit .js-organization-update-form': @onSubmit
      'click .js-submit-update-organ': @onSubmit
