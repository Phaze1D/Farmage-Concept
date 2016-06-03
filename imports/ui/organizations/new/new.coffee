{ Meteor } = require 'meteor/meteor'
{ Template } = require 'meteor/templating'
{ FlowRouter } = require 'meteor/kadira:flow-router'

OMethods = require '../../../api/collections/organizations/methods.coffee'

require './new.html'

Template.OrganizationsNew.onCreated ->

  @insert = (organization_doc) ->
    OMethods.insert.call {organization_doc}, (err, res) ->
      console.log err
      FlowRouter.go 'organizations.index' unless err?



Template.OrganizationsNew.events
  'click .js-save-b': (event, instance) ->
    $form = instance.$('.js-new-form')
    organization_doc =
      name: $form.find('[name=company_name]').val()
    instance.insert organization_doc
