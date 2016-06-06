{ Meteor } = require 'meteor/meteor'
{ Template } = require 'meteor/templating'
{ Accounts } = require 'meteor/accounts-base'
{ FlowRouter } = require 'meteor/kadira:flow-router'

UMethods = require '../../../api/collections/users/methods.coffee'

require './update.html'


Template.UserUpdate.onCreated ->

  @updateName = (profile_doc) ->
    UMethods.updateProfile.call {profile_doc}, (err,res) ->
      console.log err


  @addAddress = (address_doc, callBack) =>
    addresses = Meteor.user().profile.addresses.slice()
    addresses.push address_doc
    profile_doc =
      'profile.addresses': addresses

    UMethods.updateProfile.call {profile_doc}, callBack


  @updateAddress = (address_doc, index, callBack) =>
    addresses = Meteor.user().profile.addresses.slice()
    addresses[index] = address_doc
    profile_doc =
      'profile.addresses': addresses
    UMethods.updateProfile.call {profile_doc}, callBack


  @removeAddress = (index, callBack) =>
    addresses = (address for address, i in Meteor.user().profile.addresses when i isnt Number index )
    profile_doc =
      'profile.addresses': addresses
    UMethods.updateProfile.call {profile_doc}, callBack


  @addTelephone = (telephone_doc, callBack) =>
    telephones = Meteor.user().profile.telephones.slice()
    telephones.push telephone_doc
    profile_doc =
      'profile.telephones': telephones
    UMethods.updateProfile.call {profile_doc}, callBack


  @updateTelephone = (telephone_doc, index, callBack) =>
    telephones = Meteor.user().profile.telephones.slice()
    telephones[index] = telephone_doc
    profile_doc =
      'profile.telephones': telephones
    UMethods.updateProfile.call {profile_doc}, callBack


  @removeTelephone = (index, callBack) =>
    telephones = (telephone for telephone, i in Meteor.user().profile.telephones when i isnt Number index )
    profile_doc =
      'profile.telephones': telephones
    UMethods.updateProfile.call {profile_doc}, callBack





Template.UserUpdate.helpers
  addressInfo: ->
    ret =
      addAddress: Template.instance().addAddress
      updateAddress: Template.instance().updateAddress
      removeAddress: Template.instance().removeAddress
      addresses: Meteor.user().profile.addresses

  telephoneInfo: ->
    ret =
      addTelephone: Template.instance().addTelephone
      updateTelephone: Template.instance().updateTelephone
      removeTelephone: Template.instance().removeTelephone
      telephones: Meteor.user().profile.telephones


Template.UserUpdate.events

  'click .js-update-b': (event, instance) ->
    $form = instance.$('.js-update-form')
    profile_doc =
      'profile.first_name': $form.find('[name=first_name]').val()
      'profile.last_name': $form.find('[name=last_name]').val()

    instance.updateName profile_doc
