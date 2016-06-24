{ Meteor } = require 'meteor/meteor'
{ publicationInfo } = require '../../../mixins/server/publications_mixin.coffee'

UnitModule = require '../../units/units.coffee'
ProviderModule = require '../../providers/providers.coffee'
ExpenseModule = require '../expenses.coffee'



collections = {}
collections.unit = UnitModule.Units
collections.provider = ProviderModule.Providers

# Missing permissions and pagenation
Meteor.publish "expenses", (organization_id, parent, parent_id) ->

  info = publicationInfo organization_id, parent, parent_id
  parentDoc = info.parentDoc
  organization = info.organization

  unless(organization? && organization.hasUser(@userId)?)
    throw new Meteor.Error 'notAuthorized', 'not authorized'

  unless parentDoc?
    parentDoc = collections[parent].findOne(parent_id)
    unless(parentDoc? && parentDoc.organization_id is organization._id)
      throw new Meteor.Error 'notAuthorized', 'not authorized'



  if @userId? && parentDoc?
    return parentDoc.expenses()
  else
    @ready();


# Missing permissions and pagenation
Meteor.publish 'expense.parents', (organization_id, expense_id) ->

  info = publicationInfo organization_id, 'expense', expense_id
  expense = ExpenseModule.Expenses.findOne(expense_id)

  if @userId? && expense?
    return [
      ProviderModule.Providers.find(expense.provider_id),
      UnitModule.Units.find(expense.unit_id)
    ]
  else
    @ready()
