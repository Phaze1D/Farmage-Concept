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
  @states = new ReactiveDict
  @states.setDefault
    showAddressF: false
    showTelephoneF: false

  @autorun =>
    @organization.set(OC.Organizations.findOne(_id: FlowRouter.getParam 'id'))

  @addAddress = (address_doc) =>
    addresses = @organization.get().addresses.slice()
    addresses.push address_doc

    organization_id = @organization.get()._id
    updated_organization_doc =
      addresses: addresses

    OMethods.update.call {organization_id, updated_organization_doc}, (err, res) =>
      console.log err
      @states.set 'showAddressF',false unless err?

  @addTelephone = (telephone_doc) =>
    telephones = @organization.get().telephones.slice()
    telephones.push telephone_doc

    organization_id = @organization.get()._id
    updated_organization_doc =
      telephones: telephones

    OMethods.update.call {organization_id, updated_organization_doc}, (err, res) =>
      console.log err
      @states.set 'showTelephoneF',false unless err?


Template.OrganizationShow.onRendered ->
  console.log "OR"

Template.OrganizationShow.onDestroyed ->
  console.log "OD"


Template.OrganizationShow.helpers
  organization: ->
    Template.instance().organization.get()

  permission: ->
    Template.instance().organization.get().hasUser(Meteor.userId()).permission

  showAddressF: ->
    Template.instance().states.get 'showAddressF'

  showTelephoneF: ->
    Template.instance().states.get 'showTelephoneF'

  addAddress: ->
    ret =
      addAddress: Template.instance().addAddress

  addTelephone: ->
    ret =
      addTelephone: Template.instance().addTelephone



Template.OrganizationShow.events
  'click .js-address-add': (event, instance) ->
    instance.states.set 'showAddressF', true
    instance.states.set 'showTelephoneF', false


  'click .js-telephone-add': (event, instance) ->
    instance.states.set 'showTelephoneF', true
    instance.states.set 'showAddressF', false


  'click .js-cancel-b': (event, instance) ->
    instance.states.set 'showAddressF', false
    instance.states.set 'showTelephoneF', false
