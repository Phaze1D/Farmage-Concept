{ Meteor } = require 'meteor/meteor'
{ Template } = require 'meteor/templating'
{ Accounts } = require 'meteor/accounts-base'
{ FlowRouter } = require 'meteor/kadira:flow-router'
{ SimpleSchema } = require 'meteor/aldeed:simple-schema'
{ AddressSchema } = require '../../api/shared/contact_info.coffee'
{ ReactiveVar } = require 'meteor/reactive-var'


require './addresses.html'


Template.Address.onCreated ->
  @err = new ReactiveVar
  @state = new ReactiveVar(false)
  @uAddress = new ReactiveVar(-1)


  @autorun =>
    new SimpleSchema(
      addAddress:
        type: Function
      updateAddress:
        type: Function
      removeAddress:
        type: Function
      addresses:
        type: [AddressSchema]
    ).validate(@data)

  @callBack = (err,res) =>
    console.log err
    @err.set(err)
    @state.set(false) unless err?


Template.Address.helpers
  showForm: () ->
    Template.instance().state.get()

  uAddress: () ->
    index = if Template.instance().uAddress.get() >= 0 then Template.instance().uAddress.get() else -1
    Template.instance().data.addresses[index] if index >= 0

  form: () ->
    return type: 'update', button: 'Save' if Template.instance().uAddress.get() >= 0
    return type: 'new', button: 'Create'


Template.Address.events

  'click .js-address-add': (event, instance) ->
    instance.uAddress.set(-1)
    instance.state.set(true)

  'click .js-address-cancel': (event, instance) ->
    instance.state.set(false)

  'click .js-address-update': (event, instance) ->
    instance.uAddress.set($(event.target).closest('.js-address').attr('data-index') )
    instance.state.set(true)

  'click .js-address-remove': (event, instance) ->
    index = instance.$(event.target).closest('.js-address').attr('data-index')
    instance.uAddress.set(-1)
    instance.state.set(false)
    instance.data.removeAddress(index, instance.callBack)

  'submit .js-address-form-new': (event, instance) ->
    event.preventDefault()
    $form = instance.$('.js-address-form-new')
    address_doc =
      name: $form.find('[name=name]').val()
      street: $form.find('[name=street]').val()
      street2: $form.find('[name=street2]').val()
      city: $form.find('[name=city]').val()
      state: $form.find('[name=state]').val()
      zip_code: $form.find('[name=zip_code]').val()
      country: $form.find('[name=country]').val()

    instance.data.addAddress(address_doc, instance.callBack)

  'submit .js-address-form-update': (event, instance) ->
    event.preventDefault()
    $form = instance.$('.js-address-form-update')
    index = instance.uAddress.get()
    address_doc =
      name: $form.find('[name=name]').val()
      street: $form.find('[name=street]').val()
      street2: $form.find('[name=street2]').val()
      city: $form.find('[name=city]').val()
      state: $form.find('[name=state]').val()
      zip_code: $form.find('[name=zip_code]').val()
      country: $form.find('[name=country]').val()

    instance.data.updateAddress(address_doc, index, instance.callBack)
