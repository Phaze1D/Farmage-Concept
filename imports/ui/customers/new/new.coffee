{ Meteor } = require 'meteor/meteor'
{ Template } = require 'meteor/templating'
{ Accounts } = require 'meteor/accounts-base'
{ FlowRouter } = require 'meteor/kadira:flow-router'
{ SimpleSchema } = require 'meteor/aldeed:simple-schema'
{ ReactiveVar } = require 'meteor/reactive-var'
{ ReactiveDict } = require 'meteor/reactive-dict'

CustomerModule = require '../../../api/collections/customers/customers.coffee'
CMethods = require '../../../api/collections/customers/methods.coffee'

require './new.html'

Template.CustomersNew.onCreated ->
  @addresses = new ReactiveVar([])
  @telephones = new ReactiveVar([])

  @insert = (customer_doc) =>
    customer_doc.organization_id = FlowRouter.getParam('organization_id')
    CMethods.insert.call {customer_doc}, (err, res) ->
      console.log err
      params =
        organization_id: customer_doc.organization_id
      FlowRouter.go('customers.index', params ) unless err?

  @addAddress = (address_doc, callBack) =>
    adds = @addresses.get()
    adds.push address_doc
    @addresses.set(adds)
    callBack()

  @updateAddress = (address_doc, index, callBack) =>
    adds = @addresses.get()
    adds[index] = address_doc
    @addresses.set(adds)
    callBack()

  @removeAddress = (index, callBack) =>
    adds= (address for address, i in @addresses.get() when i isnt Number index )
    @addresses.set(adds)
    callBack()

  @addTelephone = (telephone_doc, callBack) =>
    tels = @telephones.get()
    tels.push telephone_doc
    @telephones.set(tels)
    callBack()

  @updateTelephone = (telephone_doc, index, callBack) =>
    tels = @telephones.get()
    tels[index] = telephone_doc
    @telephones.set(tels)
    callBack()

  @removeTelephone = (index, callBack) =>
    tels = (telephone for telephone, i in @telephones.get() when i isnt Number index )
    @telephones.set(tels)
    callBack()



Template.CustomersNew.helpers
  addressInfo: ->
    ret =
      addAddress: Template.instance().addAddress
      updateAddress: Template.instance().updateAddress
      removeAddress: Template.instance().removeAddress
      addresses: Template.instance().addresses.get()

  telephoneInfo: ->
    ret =
      addTelephone: Template.instance().addTelephone
      updateTelephone: Template.instance().updateTelephone
      removeTelephone: Template.instance().removeTelephone
      telephones: Template.instance().telephones.get()


Template.CustomersNew.events
  'submit .js-customer-form-new': (event, instance) ->
    event.preventDefault()
    $form = instance.$('.js-customer-form-new')
    customer_doc =
      first_name: $form.find('[name=first_name]').val()
      last_name: $form.find('[name=last_name]').val()
      company: $form.find('[name=company]').val()
      email: $form.find('[name=email]').val()
      addresses: instance.addresses.get()
      telephones: instance.telephones.get()

    instance.insert customer_doc
