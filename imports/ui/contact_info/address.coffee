{ Meteor } = require 'meteor/meteor'
{ Template } = require 'meteor/templating'
{ Accounts } = require 'meteor/accounts-base'
{ FlowRouter } = require 'meteor/kadira:flow-router'
{ SimpleSchema } = require 'meteor/aldeed:simple-schema'
{ AddressSchema } = require '../../api/shared/contact_info.coffee'
{ ReactiveVar } = require 'meteor/reactive-var'


require './address.html'


Template.Address.onCreated ->
  @state = new ReactiveVar(false)

  @autorun =>
    new SimpleSchema(
      addAddress:
        type: Function
      addresses:
        type: [AddressSchema]
    ).validate(@data)


  @callBack = (err,res) =>
    console.log err
    @state.set(false) unless err?

Template.Address.helpers
  showForm: () ->
    Template.instance().state.get()



Template.Address.events

  'click .js-address-add': (event, instance) ->
    instance.state.set(true)

  'click .js-address-cancel': (event, instance) ->
    instance.state.set(false)

  'click .js-address-create': (event, instance) ->
    $form = instance.$('.js-address-form')
    address_doc =
      name: $form.find('[name=name]').val()
      street: $form.find('[name=street]').val()
      street2: $form.find('[name=street2]').val()
      city: $form.find('[name=city]').val()
      state: $form.find('[name=state]').val()
      zip_code: $form.find('[name=zip_code]').val()
      country: $form.find('[name=country]').val()

    instance.data.addAddress(address_doc, instance.callBack)
