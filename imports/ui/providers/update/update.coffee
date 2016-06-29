{ Meteor } = require 'meteor/meteor'
{ Template } = require 'meteor/templating'
{ Accounts } = require 'meteor/accounts-base'
{ FlowRouter } = require 'meteor/kadira:flow-router'
{ SimpleSchema } = require 'meteor/aldeed:simple-schema'
{ ReactiveVar } = require 'meteor/reactive-var'

OrganizationModule = require '../../../api/collections/organizations/organizations.coffee'
ProviderModule = require '../../../api/collections/providers/providers.coffee'
PMethods = require '../../../api/collections/providers/methods.coffee'

require './update.html'

Template.ProvidersUpdate.onCreated ->
  @provider = new ReactiveVar()
  unpro_id = FlowRouter.getParam 'child_id'

  @autorun =>
    provider = ProviderModule.Providers.findOne unpro_id
    @provider.set provider

  @update = (provider_doc) =>
    organization_id = FlowRouter.getParam 'organization_id'
    provider_id = @provider.get()._id
    PMethods.update.call {organization_id, provider_id, provider_doc}, (err, res) =>
      console.log err
      params =
        organization_id: organization_id
        child_id: provider_id
      FlowRouter.go('providers.show', params) unless err?

  @addAddress = (address_doc, callBack) =>
    addresses = @provider.get().addresses.slice()
    addresses.push address_doc
    organization_id = FlowRouter.getParam 'organization_id'
    provider_id = @provider.get()._id
    provider_doc =
      addresses: addresses
    PMethods.update.call {organization_id, provider_id, provider_doc}, callBack


  @updateAddress = (address_doc, index, callBack) =>
    addresses = @provider.get().addresses.slice()
    addresses[index] = address_doc
    organization_id = FlowRouter.getParam 'organization_id'
    provider_id = @provider.get()._id
    provider_doc =
      addresses: addresses
    PMethods.update.call {organization_id, provider_id, provider_doc}, callBack

  @removeAddress = (index, callBack) =>
    addresses = (address for address, i in @provider.get().addresses when i isnt Number index )
    organization_id = FlowRouter.getParam 'organization_id'
    provider_id = @provider.get()._id
    provider_doc =
      addresses: addresses
    PMethods.update.call {organization_id, provider_id, provider_doc}, callBack

  @addTelephone = (telephone_doc, callBack) =>
    telephones = @provider.get().telephones.slice()
    telephones.push telephone_doc
    organization_id = FlowRouter.getParam 'organization_id'
    provider_id = @provider.get()._id
    provider_doc =
      telephones: telephones
    PMethods.update.call {organization_id, provider_id, provider_doc}, callBack


  @updateTelephone = (telephone_doc, index, callBack) =>
    telephones = @provider.get().telephones.slice()
    telephones[index] = telephone_doc
    organization_id = FlowRouter.getParam 'organization_id'
    provider_id = @provider.get()._id
    provider_doc =
      telephones: telephones
    PMethods.update.call {organization_id, provider_id, provider_doc}, callBack

  @removeTelephone = (index, callBack) =>
    telephones = (telephone for telephone, i in @provider.get().telephones when i isnt Number index )
    organization_id = FlowRouter.getParam 'organization_id'
    provider_id = @provider.get()._id
    provider_doc =
      telephones: telephones
    PMethods.update.call {organization_id, provider_id, provider_doc}, callBack



Template.ProvidersUpdate.helpers
  provider: () ->
    Template.instance().provider.get()

  organization: () ->
    OrganizationModule.Organizations.findOne(FlowRouter.getParam 'organization_id')

  addressInfo: ->
    ret =
      addAddress: Template.instance().addAddress
      updateAddress: Template.instance().updateAddress
      removeAddress: Template.instance().removeAddress
      addresses: Template.instance().provider.get().addresses

  telephoneInfo: ->
    ret =
      addTelephone: Template.instance().addTelephone
      updateTelephone: Template.instance().updateTelephone
      removeTelephone: Template.instance().removeTelephone
      telephones: Template.instance().provider.get().telephones


Template.ProvidersUpdate.events

  'submit .js-provider-form-update': (event, instance) ->
    event.preventDefault()
    $form = instance.$('.js-provider-form-update')
    provider_doc =
      first_name: $form.find('[name=first_name]').val()
      last_name: $form.find('[name=last_name]').val()
      company: $form.find('[name=company]').val()
      email: $form.find('[name=email]').val()
      notes: $form.find('[name=notes]').val()
      date_of_birth: $form.find('[name=date_of_birth]').val()


    instance.update provider_doc
