
IndexMixin = require '../../../mixins/index_mixin.coffee'
OrganizationModule = require '../../../../api/collections/organizations/organizations.coffee'

require './index.jade'

class OrganizationsIndex extends IndexMixin
  @register 'organizations.index'


  onRendered: ->
    super


  organizations: ->
    @resizeCard()
    OrganizationModule.Organizations.find()

  founder: (organization) ->
    Meteor.users.findOne organization.founder().user_id
