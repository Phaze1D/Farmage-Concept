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

  @autorun =>
    new SimpleSchema(
      addTelephone:
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


Template.Telephone.events

  'click .js-telephone-add': (event, instance) ->
    instance.state.set(true)

  'click .js-telephone-cancel': (event, instance) ->
    instance.state.set(false)

  'click .js-telephone-create': (event, instance) ->
    $form = instance.$('.js-telephone-form')
    telephone_doc =
      name: $form.find('[name=name]').val()
      number: $form.find('[name=number]').val()

    instance.data.addTelephone(telephone_doc, instance.callBack)
