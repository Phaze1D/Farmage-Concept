{ Meteor } = require 'meteor/meteor'
{ Template } = require 'meteor/templating'
{ Accounts } = require 'meteor/accounts-base'
{ FlowRouter } = require 'meteor/kadira:flow-router'
{ SimpleSchema } = require 'meteor/aldeed:simple-schema'
{ ReactiveVar } = require 'meteor/reactive-var'

OC = require '../../../api/collections/organizations/organizations.coffee'
OMethods = require '../../../api/collections/organizations/methods.coffee'

require './show.html'

Template.OrganizationShow.onCreated ->
  @organization = new ReactiveVar
  @showAddressF = new ReactiveVar(false)

  @autorun =>
    @organization.set(OC.Organizations.findOne(_id: FlowRouter.getParam 'id'))

  @addAddress = (address_doc) ->
    addresses = @organization.get().addresses
    addresses.push address_doc
    updated_organization_doc =
      addresses: addresses
    organization_id = @organization.get()._id

    OMethods.update.call {organization_id, updated_organization_doc}, (err, res) =>
      console.log err
      @showAddressF.set false unless err?


Template.OrganizationShow.helpers
  organization: ->
    Template.instance().organization.get()

  permission: ->
    Template.instance().organization.get().hasUser(Meteor.userId()).permission

  showAddressF: ->
    Template.instance().showAddressF.get()



Template.OrganizationShow.events
  'click .js-address-add': (event, instance) ->
    instance.showAddressF.set(true)
  'click .js-cancel-b': (event, instance) ->
    instance.showAddressF.set(false)

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

    instance.addAddress(address_doc)
