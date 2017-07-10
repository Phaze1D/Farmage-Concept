UMethods = require '../../../../api/collections/users/methods.coffee'
OrganizationModule = require '../../../../api/collections/organizations/organizations.coffee'

require './update.jade'

class OUsersUpdate extends BlazeComponent
  @register 'ousersUpdate'

  constructor: (args) ->
    # body...

  onRendered: ->
    super
    $('#right-paper-header-panel').addClass('touchScroll')

  ouser: ->
    Meteor.users.findOne @data().update_id

  email: ->
    @ouser().emails[0].address

  permission: (permission) ->
    organ = OrganizationModule.Organizations.findOne(_id: FlowRouter.getParam 'organization_id')
    if organ?
      op = organ.hasUser(@data().update_id)
      if op.permission[permission]
        'on'
      else
        'off'

  convert: (value) ->
    return true if value is 'on'
    return false if value is 'off'

  updateUser: (permission) ->
    organization_id = FlowRouter.getParam('organization_id')
    update_user_id = @data().update_id
    UMethods.updatePermission.call {update_user_id, organization_id, permission}, (err, res) =>
      console.log err
      $('.js-hide-new').trigger('click')  unless err?


  onToggleGrid: (event) ->
    $(event.currentTarget).find('.js-toggle').trigger('click')


  onSubmit: (event) ->
    event.preventDefault()
    form = $('.js-ousers-update-form')

    permission =
      owner: @convert form.find('.js-toggle-box[permission=owner]').find('.js-toggle').attr('toggled')
      viewer: @convert form.find('.js-toggle-box[permission=viewer]').find('.js-toggle').attr('toggled')
      expenses_manager: @convert form.find('.js-toggle-box[permission=expenses_manager]').find('.js-toggle').attr('toggled')
      sells_manager: @convert form.find('.js-toggle-box[permission=sells_manager]').find('.js-toggle').attr('toggled')
      units_manager: @convert form.find('.js-toggle-box[permission=units_manager]').find('.js-toggle').attr('toggled')
      inventories_manager: @convert form.find('.js-toggle-box[permission=inventories_manager]').find('.js-toggle').attr('toggled')
      users_manager: @convert form.find('.js-toggle-box[permission=users_manager]').find('.js-toggle').attr('toggled')
    @updateUser(permission)


  events: ->
    super.concat
      'click .js-toggle-grid': @onToggleGrid
      'click .js-submit-update-ouser': @onSubmit
      'submit .js-ousers-update-form': @onSubmit
