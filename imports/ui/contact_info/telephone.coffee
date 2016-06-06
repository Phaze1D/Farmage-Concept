{ Meteor } = require 'meteor/meteor'
{ Template } = require 'meteor/templating'
{ Accounts } = require 'meteor/accounts-base'
{ FlowRouter } = require 'meteor/kadira:flow-router'
{ SimpleSchema } = require 'meteor/aldeed:simple-schema'
{ TelephoneSchema } = require '../../api/shared/contact_info.coffee'
{ ReactiveVar } = require 'meteor/reactive-var'


require './telephone.html'

Template.Telephone.onCreated ->
  @state = new ReactiveVar(false)
  @uTelephone = new ReactiveVar(-1)

  @autorun =>
    new SimpleSchema(
      addTelephone:
        type: Function
      updateTelephone:
        type: Function
      removeTelephone:
        type: Function
      telephones:
        type: [TelephoneSchema]
    ).validate(@data)

  @callBack = (err,res) =>
    console.log err
    @state.set(false) unless err?

Template.Telephone.helpers
  showForm: () ->
    Template.instance().state.get()

  uTelephone: () ->
    index = if Template.instance().uTelephone.get() >= 0 then Template.instance().uTelephone.get() else -1
    Template.instance().data.telephones[index] if index >= 0


Template.Telephone.events

  'click .js-telephone-add': (event, instance) ->
    instance.uTelephone.set(-1)
    instance.state.set(true)

  'click .js-telephone-cancel': (event, instance) ->
    instance.state.set(false)

  'click .js-telephone-update': (event, instance) ->
    instance.uTelephone.set($(event.target).closest('.js-telephone').attr('data-index') )
    instance.state.set(true)

  'click .js-telephone-remove': (event, instance) ->
    index = $(event.target).closest('.js-telephone').attr('data-index')
    instance.uTelephone.set(-1)
    instance.state.set(false)
    instance.data.removeTelephone(index, instance.callBack)

  'click .js-telephone-create': (event, instance) ->
    $form = instance.$('.js-telephone-form')
    telephone_doc =
      name: $form.find('[name=name]').val()
      number: $form.find('[name=number]').val()

    instance.data.addTelephone(telephone_doc, instance.callBack)

  'click .js-telephone-save': (event, instance) ->
    $form = instance.$('.js-telephone-form')
    index = instance.uTelephone.get()
    telephone_doc =
      name: $form.find('[name=name]').val()
      number: $form.find('[name=number]').val()

    instance.data.updateTelephone(telephone_doc, index, instance.callBack)
