{ Meteor } = require 'meteor/meteor'
{ publicationInfo } = require '../../../mixins/server/publications_mixin.coffee'


UnitModule = require '../../units/units.coffee'
ProviderModule = require '../../providers/providers.coffee'
ExpenseModule = require '../expenses.coffee'

collections = {}
collections.unit = UnitModule.Units
collections.provider = ProviderModule.Providers

Meteor.publish "expenses", (organization_id, parent, parent_id, search, limit) ->

  new SimpleSchema(
    search:
      type: String
      optional: true
  ).validate({search: search})

  info = publicationInfo organization_id, parent, parent_id
  parentDoc = info.parentDoc
  organization = info.organization

  if organization? && organization.hasUser(@userId)?
    permissions = organization.hasUser(@userId).permission

  unless permissions?
    throw new Meteor.Error 'notAuthorized', 'not authorized'

  unless parentDoc?
    parentDoc = collections[parent].findOne(parent_id)
    unless(parentDoc? && parentDoc.organization_id is organization._id)
      throw new Meteor.Error 'notAuthorized', 'not authorized'


  if @userId? && parentDoc? && (permissions.viewer || permissions.expenses_manager || permissions.owner)
    return parentDoc.expenses(limit, search)
  else
    @ready();


Meteor.publish 'expense.parents', (organization_id, expense_id) ->

  info = publicationInfo organization_id, 'expense', expense_id
  organization = info.organization

  if organization? && organization.hasUser(@userId)?
    permissions = organization.hasUser(@userId).permission

  unless permissions?
    throw new Meteor.Error 'notAuthorized', 'not authorized'

  expense = ExpenseModule.Expenses.findOne(expense_id)
  unless(expense? && expense.organization_id is organization._id)
    throw new Meteor.Error 'notAuthorized', 'not authorized'

  if @userId? && (permissions.viewer || permissions.expenses_manager || permissions.owner)
    return [
      expense.provider(),
      expense.unit()
    ]
  else
    @ready()
