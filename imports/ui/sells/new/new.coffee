{ Meteor } = require 'meteor/meteor'
{ Template } = require 'meteor/templating'
{ Accounts } = require 'meteor/accounts-base'
{ FlowRouter } = require 'meteor/kadira:flow-router'
{ SimpleSchema } = require 'meteor/aldeed:simple-schema'
{ ReactiveVar } = require 'meteor/reactive-var'
{ ReactiveDict } = require 'meteor/reactive-dict'


OrganizationModule = require '../../../api/collections/organizations/organizations.coffee'
SellModule = require '../../../api/collections/sells/sells.coffee'

require '../../customers/selector/selector.coffee'
require '../../products/selector/selector.coffee'
require '../../inventories/selector/selector.coffee'
require './new.html'


Template.SellsNew.onCreated ->
  @selector = new ReactiveVar(false)
  @customer = new ReactiveVar
  @details = new ReactiveVar([])


  @selectProduct = (product_id) =>


  @selectInventory = (inventory_id) =>



Template.SellsNew.helpers
  details: ->
    Template.instance().details.get()

  selector: ->
    Template.instance().selector.get()

  pselect: ->
    select: Template.instance().selectProduct

  iselect: ->
    select: Template.instance().selectInventory


Template.SellsNew.events
  'click .js-add-product': (event, instance) ->
    instance.selector.set(true)

  'mousedown .top': (event, instance) ->
    container = instance.$('.js-selector')
    instance.selector.set(false) if  !container.is(event.target) &&
                                    container.has(event.target).length is 0 &&
                                    instance.selector.get()
