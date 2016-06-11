{ Meteor } = require 'meteor/meteor'
{ Template } = require 'meteor/templating'
{ Accounts } = require 'meteor/accounts-base'
{ FlowRouter } = require 'meteor/kadira:flow-router'
{ SimpleSchema } = require 'meteor/aldeed:simple-schema'
{ ReactiveVar } = require 'meteor/reactive-var'
{ ReactiveDict } = require 'meteor/reactive-dict'

UMethods = require '../../../api/collections/users/methods.coffee'

require './new.html'


Template.OUsersNew.onCreated ->

  @inviteUser = (invited_user_doc, permission) =>
    organization_id = FlowRouter.getParam('organization_id')
    UMethods.inviteUser.call {invited_user_doc, organization_id, permission}, (err, res) =>
      console.log err
      params =
        organization_id: organization_id
      FlowRouter.go('ousers.index', params) unless err?

Template.OUsersNew.helpers



Template.OUsersNew.events
  'submit .js-ouser-form-new': (event, instance) ->
    event.preventDefault()
    $form = instance.$('.js-ouser-form-new')
    invited_user_doc =
      emails: [
        address: $form.find('[name=email]').val()
      ]
      profile:
        first_name: 'test'
    permission =
      owner: $form.find('[name=owner]').prop('checked')
      editor: $form.find('[name=editor]').prop('checked')
      expenses_manager: $form.find('[name=expenses_manager]').prop('checked')
      sells_manager: $form.find('[name=sells_manager]').prop('checked')
      units_manager: $form.find('[name=units_manager]').prop('checked')
      inventories_manager: $form.find('[name=inventories_manager]').prop('checked')
      users_manager: $form.find('[name=users_manager]').prop('checked')
    instance.inviteUser(invited_user_doc, permission)
