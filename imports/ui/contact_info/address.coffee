{ Meteor } = require 'meteor/meteor'
{ Template } = require 'meteor/templating'
{ Accounts } = require 'meteor/accounts-base'
{ FlowRouter } = require 'meteor/kadira:flow-router'
{ SimpleSchema } = require 'meteor/aldeed:simple-schema'

require './address.html'


Template.Address.onCreated ->
  @autorun =>
    new SimpleSchema(
      addAddress:
        type: Function
    ).validate(@data)


Template.Address.events

  'click .js-create-b': (event, instance) ->
    $form = instance.$('.js-address-form')
    address_doc =
      name: $form.find('[name=name]').val()
      street: $form.find('[name=street]').val()
      street2: $form.find('[name=street2]').val()
      city: $form.find('[name=city]').val()
      state: $form.find('[name=state]').val()
      zip_code: $form.find('[name=zip_code]').val()
      country: $form.find('[name=country]').val()

    instance.data.addAddress(address_doc)
