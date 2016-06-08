{ Meteor } = require 'meteor/meteor'
{ Template } = require 'meteor/templating'
{ Accounts } = require 'meteor/accounts-base'
{ FlowRouter } = require 'meteor/kadira:flow-router'
{ SimpleSchema } = require 'meteor/aldeed:simple-schema'
{ ReactiveVar } = require 'meteor/reactive-var'

OC = require '../../../api/collections/organizations/organizations.coffee'
OMethods = require '../../../api/collections/organizations/methods.coffee'

require './update.html'


Template.OrganizationUpdate.onCreated ->
  @organization = new ReactiveVar

  @autorun =>
    organ = OC.Organizations.findOne(_id: FlowRouter.getParam 'organization_id')
    @organization.set(organ)

  @addAddress = (address_doc, callBack) =>
    addresses = @organization.get().addresses.slice()
    addresses.push address_doc
    organization_id = @organization.get()._id
    updated_organization_doc =
      addresses: addresses
    OMethods.update.call {organization_id, updated_organization_doc}, callBack

  @updateAddress = (address_doc, index, callBack) =>
    addresses = @organization.get().addresses.slice()
    addresses[index] = address_doc
    organization_id = @organization.get()._id
    updated_organization_doc =
      addresses: addresses
    OMethods.update.call {organization_id, updated_organization_doc}, callBack


  @removeAddress = (index, callBack) =>
    addresses = (address for address, i in @organization.get().addresses when i isnt Number index )
    organization_id = @organization.get()._id
    updated_organization_doc =
      addresses: addresses
    OMethods.update.call {organization_id, updated_organization_doc}, callBack


  @addTelephone = (telephone_doc, callBack) =>
    telephones = @organization.get().telephones.slice()
    telephones.push telephone_doc
    organization_id = @organization.get()._id
    updated_organization_doc =
      telephones: telephones
    OMethods.update.call {organization_id, updated_organization_doc}, callBack


  @updateTelephone = (telephone_doc, index, callBack) =>
    telephones = @organization.get().telephones.slice()
    telephones[index] = telephone_doc
    organization_id = @organization.get()._id
    updated_organization_doc =
      telephones: telephones
    OMethods.update.call {organization_id, updated_organization_doc}, callBack


  @removeTelephone = (index, callBack) =>
    telephones = (telephone for telephone, i in @organization.get().telephones when i isnt Number index )
    organization_id = @organization.get()._id
    updated_organization_doc =
      telephones: telephones
    OMethods.update.call {organization_id, updated_organization_doc}, callBack




Template.OrganizationUpdate.helpers
  organization: ->
    Template.instance().organization.get()

  permission: ->
    Template.instance().organization.get().hasUser(Meteor.userId()).permission


  addressInfo: ->
    ret =
      addAddress: Template.instance().addAddress
      updateAddress: Template.instance().updateAddress
      removeAddress: Template.instance().removeAddress
      addresses: Template.instance().organization.get().addresses

  telephoneInfo: ->
    ret =
      addTelephone: Template.instance().addTelephone
      updateTelephone: Template.instance().updateTelephone
      removeTelephone: Template.instance().removeTelephone
      telephones: Template.instance().organization.get().telephones


Template.OrganizationUpdate.events
