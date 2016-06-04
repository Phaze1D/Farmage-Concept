{ Meteor } = require 'meteor/meteor'
{ Template } = require 'meteor/templating'
{ Accounts } = require 'meteor/accounts-base'
{ FlowRouter } = require 'meteor/kadira:flow-router'
{ SimpleSchema } = require 'meteor/aldeed:simple-schema'

require './telephone.html'

Template.Telephone.onCreated ->
  @autorun =>
    new SimpleSchema(
      addTelephone:
        type: Function
    ).validate(@data)



Template.Telephone.events
  'click .js-create-b': (event, instance) ->
    $form = instance.$('.js-telephone-form')
    telephone_doc =
      name: $form.find('[name=name]').val()
      number: $form.find('[name=number]').val()

    instance.data.addTelephone(telephone_doc)
