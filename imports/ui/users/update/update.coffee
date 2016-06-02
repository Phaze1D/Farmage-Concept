{ Meteor } = require 'meteor/meteor'
{ Template } = require 'meteor/templating'
{ Accounts } = require 'meteor/accounts-base'
{ FlowRouter } = require 'meteor/kadira:flow-router'

UMethods = require '../../../api/collections/users/methods.coffee'

require './update.html'


Template.UserUpdate.onCreated ->
  
  @updateProfile = (profile_doc) ->
    UMethods.updateProfile.call {profile_doc}, (err,res) ->
      console.log err
      console.log Meteor.user()


Template.UserUpdate.events
  'click .js-update-b': (event, instance) ->
    $form = instance.$('.js-update-form')
    profile_doc =
      first_name: $form.find('[name=first_name]').val()
      last_name: $form.find('[name=last_name]').val()

    instance.updateProfile profile_doc
