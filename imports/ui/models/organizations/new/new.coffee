
require './new.jade'

class OrganizationsNew extends BlazeComponent
  @register 'organizations.new'

  constructor: (args) ->


  insert: (organization_doc) ->



  onSubmit: (event) ->
    event.preventDefault()
    $form = $('.js-organization-form-new')
    organization_doc =
      name: $form.find('[name=company_name]').val()
    @insert organization_doc

  events: ->
    super.concat
      'submit .js-organization-new-form': @onSubmit
      'click .js-submit-new-organ': @onSubmit
