
OrganizationModule = require '../../../../api/collections/organizations/organizations.coffee'
OMethods = require '../../../../api/collections/organizations/methods.coffee'

require './new.jade'

class OrganizationsNew extends BlazeComponent
  @register 'organizationsNew'

  constructor: (args) ->

  onCreated: ->
    super
    @schema = OrganizationModule.Organizations.simpleSchema()

  onRendered: ->
    super
    $('#right-paper-header-panel').addClass('touchScroll')


  insert: (organization_doc) ->
    OMethods.insert.call {organization_doc}, (err, res) =>
      console.log err
      if err?
        pins = @findAll('.pinput')
        $(pins).trigger('focusin')
        $(pins).trigger('focusout')
      $('.js-hide-new').trigger('click') unless err


  onSubmit: (event) ->
    event.preventDefault()
    $form = $('.js-organization-new-form')

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

    @insert organization_doc


  events: ->
    super.concat
      'submit .js-organization-new-form': @onSubmit
      'click .js-submit-new-organ': @onSubmit
