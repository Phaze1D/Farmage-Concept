{ Meteor } = require 'meteor/meteor'
{ Template } = require 'meteor/templating'
{ Accounts } = require 'meteor/accounts-base'
{ FlowRouter } = require 'meteor/kadira:flow-router'
{ SimpleSchema } = require 'meteor/aldeed:simple-schema'
{ ReactiveVar } = require 'meteor/reactive-var'

OrganizationModule = require '../../../api/collections/organizations/organizations.coffee'
CustomerModule = require '../../../api/collections/customers/customers.coffee'
CMethods = require '../../../api/collections/customers/methods.coffee'

require './update.html'

Template.CustomersUpdate.onCreated ->
  @customer = new ReactiveVar()

  @autorun =>
    customer = CustomerModule.Customers.findOne(FlowRouter.getParam 'child_id')
    @customer.set customer

  @update = (customer_doc) =>
    organization_id = FlowRouter.getParam 'organization_id'
    customer_id = @customer.get()._id
    CMethods.update.call {organization_id, customer_id, customer_doc}, (err, res) =>
      console.log err
      params =
        organization_id: organization_id
        child_id: customer_id
      FlowRouter.go('customers.show', params) unless err?

  @addAddress = (address_doc, callBack) =>
    addresses = @customer.get().addresses.slice()
    addresses.push address_doc
    organization_id = FlowRouter.getParam 'organization_id'
    customer_id = @customer.get()._id
    customer_doc =
      addresses: addresses
    CMethods.update.call {organization_id, customer_id, customer_doc}, callBack


  @updateAddress = (address_doc, index, callBack) =>
    addresses = @customer.get().addresses.slice()
    addresses[index] = address_doc
    organization_id = FlowRouter.getParam 'organization_id'
    customer_id = @customer.get()._id
    customer_doc =
      addresses: addresses
    CMethods.update.call {organization_id, customer_id, customer_doc}, callBack

  @removeAddress = (index, callBack) =>
    addresses = (address for address, i in @customer.get().addresses when i isnt Number index )
    organization_id = FlowRouter.getParam 'organization_id'
    customer_id = @customer.get()._id
    customer_doc =
      addresses: addresses
    CMethods.update.call {organization_id, customer_id, customer_doc}, callBack

  @addTelephone = (telephone_doc, callBack) =>
    telephones = @customer.get().telephones.slice()
    telephones.push telephone_doc
    organization_id = FlowRouter.getParam 'organization_id'
    customer_id = @customer.get()._id
    customer_doc =
      telephones: telephones
    CMethods.update.call {organization_id, customer_id, customer_doc}, callBack


  @updateTelephone = (telephone_doc, index, callBack) =>
    telephones = @customer.get().telephones.slice()
    telephones[index] = telephone_doc
    organization_id = FlowRouter.getParam 'organization_id'
    customer_id = @customer.get()._id
    customer_doc =
      telephones: telephones
    CMethods.update.call {organization_id, customer_id, customer_doc}, callBack

  @removeTelephone = (index, callBack) =>
    telephones = (telephone for telephone, i in @customer.get().telephones when i isnt Number index )
    organization_id = FlowRouter.getParam 'organization_id'
    customer_id = @customer.get()._id
    customer_doc =
      telephones: telephones
    CMethods.update.call {organization_id, customer_id, customer_doc}, callBack


Template.CustomersUpdate.onRendered ->
  @autorun =>


Template.CustomersUpdate.helpers
  customer: () ->
    Template.instance().customer.get()

  organization: () ->
    OrganizationModule.Organizations.findOne(FlowRouter.getParam 'organization_id')

  addressInfo: ->
    ret =
      addAddress: Template.instance().addAddress
      updateAddress: Template.instance().updateAddress
      removeAddress: Template.instance().removeAddress
      addresses: Template.instance().customer.get().addresses

  telephoneInfo: ->
    ret =
      addTelephone: Template.instance().addTelephone
      updateTelephone: Template.instance().updateTelephone
      removeTelephone: Template.instance().removeTelephone
      telephones: Template.instance().customer.get().telephones


Template.CustomersUpdate.events

  'submit .js-customer-form-update': (event, instance) ->
    event.preventDefault()
    $form = instance.$('.js-customer-form-update')
    customer_doc =
      first_name: $form.find('[name=first_name]').val()
      last_name: $form.find('[name=last_name]').val()
      company: $form.find('[name=company]').val()
      email: $form.find('[name=email]').val()
      notes: $form.find('[name=notes]').val()
      date_of_birth: $form.find('[name=date_of_birth]').val()


    instance.update customer_doc
