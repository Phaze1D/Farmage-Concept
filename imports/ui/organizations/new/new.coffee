{ Meteor } = require 'meteor/meteor'
{ Template } = require 'meteor/templating'
{ FlowRouter } = require 'meteor/kadira:flow-router'
{ ReactiveVar } = require 'meteor/reactive-var'


OMethods = require '../../../api/collections/organizations/methods.coffee'

require './new.html'

Template.OrganizationsNew.onCreated ->
  @err = new ReactiveVar

  @insert = (organization_doc) =>
    OMethods.insert.call {organization_doc}, (err, res) =>
      console.log err
      @err.set err
      FlowRouter.go 'organizations.index' unless err?



Template.OrganizationsNew.events
  'submit .js-organization-form-new': (event, instance) ->
    event.preventDefault()
    $form = instance.$('.js-organization-form-new')
    organization_doc =
      name: $form.find('[name=company_name]').val()
    instance.insert organization_doc
