UMethods = require '../../../../api/collections/users/methods.coffee'

require './new.jade'

class OUsersNew extends BlazeComponent
  @register 'ousersNew'

  constructor: (args) ->
    # body...

  convert: (value) ->
    return true if value is 'on'
    return false if value is 'off'

  inviteUser: (invited_user_doc, permission) ->
    organization_id = FlowRouter.getParam('organization_id')
    UMethods.inviteUser.call {invited_user_doc, organization_id, permission}, (err, res) =>
      console.log err
      $('.js-hide-new').trigger('click')  unless err?



  onToggleGrid: (event) ->
    $(event.currentTarget).find('.js-toggle').trigger('click')


  onSubmit: (event) ->
    event.preventDefault()
    form = $('.js-ousers-new-form')
    invited_user_doc =
      emails: [
        address: form.find('[name=email]').val()
      ]
      profile:
        first_name: form.find('[name=first_name]').val()
        last_name: form.find('[name=last_name]').val()
    permission =
      owner: @convert form.find('.js-toggle-box[permission=owner]').find('.js-toggle').attr('toggled')
      viewer: @convert form.find('.js-toggle-box[permission=viewer]').find('.js-toggle').attr('toggled')
      expenses_manager: @convert form.find('.js-toggle-box[permission=expenses_manager]').find('.js-toggle').attr('toggled')
      sells_manager: @convert form.find('.js-toggle-box[permission=sells_manager]').find('.js-toggle').attr('toggled')
      units_manager: @convert form.find('.js-toggle-box[permission=units_manager]').find('.js-toggle').attr('toggled')
      inventories_manager: @convert form.find('.js-toggle-box[permission=inventories_manager]').find('.js-toggle').attr('toggled')
      users_manager: @convert form.find('.js-toggle-box[permission=users_manager]').find('.js-toggle').attr('toggled')
    @inviteUser(invited_user_doc, permission)


  events: ->
    super.concat
      'click .js-toggle-grid': @onToggleGrid
      'click .js-submit-new-ouser': @onSubmit
      'submit .js-ousers-new-form': @onSubmit
