{ Meteor } = require 'meteor/meteor'
{ Template } = require 'meteor/templating'
{ Accounts } = require 'meteor/accounts-base'
{ FlowRouter } = require 'meteor/kadira:flow-router'
{ SimpleSchema } = require 'meteor/aldeed:simple-schema'
{ ReactiveVar } = require 'meteor/reactive-var'
{ ReactiveDict } = require 'meteor/reactive-dict'

OrganizationModule = require '../../../api/collections/organizations/organizations.coffee'
UMethods = require '../../../api/collections/users/methods.coffee'

require './update.html'


Template.OUsersUpdate.onCreated ->


  @updatePermission = (permission) =>
    organization_id = FlowRouter.getParam 'organization_id'
    update_user_id = FlowRouter.getParam 'child_id'
    UMethods.updatePermission.call {update_user_id, organization_id, permission}, (err, res) ->
      console.log err
      params =
        organization_id: organization_id
        child_id: update_user_id
      FlowRouter.go('ousers.show', params) unless err?

  @removeUser = () =>
    organization_id = FlowRouter.getParam 'organization_id'
    update_user_id = FlowRouter.getParam 'child_id'
    UMethods.removeFromOrganization.call {update_user_id, organization_id}, (err, res) ->
      console.log err
      params =
        organization_id: organization_id
      FlowRouter.go('ousers.index', params) unless err?

Template.OUsersUpdate.helpers

  ouser: (user_id) ->
    organ = OrganizationModule.Organizations.findOne FlowRouter.getParam 'organization_id'
    organ.hasUser user_id

  user: ->
    Meteor.users.findOne FlowRouter.getParam 'child_id'

  email: ->
    user = Meteor.users.findOne FlowRouter.getParam 'child_id'
    user.emails[0]

  checked: ( permission ) ->
    checked: true if permission

Template.OUsersUpdate.events

  'click .js-remove-user': (event, instance) ->
    instance.removeUser()

  'submit .js-ouser-form-update': (event, instance) ->
    event.preventDefault()
    $form = instance.$('.js-ouser-form-update')
    permission =
      owner: $form.find('[name=owner]').prop('checked')
      editor: $form.find('[name=editor]').prop('checked')
      expenses_manager: $form.find('[name=expenses_manager]').prop('checked')
      sells_manager: $form.find('[name=sells_manager]').prop('checked')
      units_manager: $form.find('[name=units_manager]').prop('checked')
      inventories_manager: $form.find('[name=inventories_manager]').prop('checked')
      users_manager: $form.find('[name=users_manager]').prop('checked')

    instance.updatePermission(permission)
