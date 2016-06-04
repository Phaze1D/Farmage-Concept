{ Meteor } = require 'meteor/meteor'
{ Template } = require 'meteor/templating'
{ Accounts } = require 'meteor/accounts-base'
{ FlowRouter } = require 'meteor/kadira:flow-router'
{ SimpleSchema } = require 'meteor/aldeed:simple-schema'
{ ReactiveVar } = require 'meteor/reactive-var'
{ ReactiveDict } = require 'meteor/reactive-dict'

OC = require '../../../api/collections/organizations/organizations.coffee'
OMethods = require '../../../api/collections/organizations/methods.coffee'

require './show.html'

require '../../contact_info/address.coffee'
require '../../contact_info/telephone.coffee'

Template.OrganizationShow.onCreated ->
  @organization = new ReactiveVar


  @autorun =>
    @organization.set(OC.Organizations.findOne(_id: FlowRouter.getParam 'id'))

  @addAddress = (address_doc, callBack) =>
    addresses = @organization.get().addresses.slice()
    addresses.push address_doc

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


Template.OrganizationShow.onRendered ->

Template.OrganizationShow.onDestroyed ->


Template.OrganizationShow.helpers
  organization: ->
    Template.instance().organization.get()

  permission: ->
    Template.instance().organization.get().hasUser(Meteor.userId()).permission


  addressInfo: ->
    ret =
      addAddress: Template.instance().addAddress
      addresses: Template.instance().organization.get().addresses

  telephoneInfo: ->
    ret =
      addTelephone: Template.instance().addTelephone
      telephones: Template.instance().organization.get().telephones


Template.OrganizationShow.events
