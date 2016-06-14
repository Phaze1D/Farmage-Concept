{ Meteor } = require 'meteor/meteor'
{ Template } = require 'meteor/templating'
{ Accounts } = require 'meteor/accounts-base'
{ FlowRouter } = require 'meteor/kadira:flow-router'
{ SimpleSchema } = require 'meteor/aldeed:simple-schema'
{ ReactiveVar } = require 'meteor/reactive-var'

OrganizationModule = require '../../../api/collections/organizations/organizations.coffee'
InventoryModule = require '../../../api/collections/inventories/inventories.coffee'

require './new.html'


Template.InventoriesNew.onCreated ->
  @yields = new ReactiveVar([])
  @showAdd = new ReactiveVar(false)

  @addYield = (yield_doc) =>
    ylds = @yields.get()
    ylds.push yield_doc
    @yields.set ylds 

  @removeYield = (index) =>
    ylds = (_yield for _yield, i in @yields.get() when i isnt Number index )
    @yields.set ylds

Template.InventoriesNew.helpers
  showAdd: ->
    Template.instance().showAdd.get()

  yields: ->
    Template.instance().yields.get()

Template.InventoriesNew.events
  'click .js-yields-add': (event, instance) ->
    instance.showAdd.set(true)

  'click .js-yield-cancel': (event, instance) ->
    instance.showAdd.set(false)

  'click .js-yield-insert': (event, instance) ->
    instance.showAdd.set(false)
    yield_doc =
      yield_id: instance.$('[name=yield_id]').val()
      amount_taken: instance.$('[name=amount_taken]').val()

    instance.addYield yield_doc

  'click .js-yield-remove': (event, instance) ->
    index =  instance.$(event.target).closest('.js-yield').attr('data-index')
    instance.removeYield index
