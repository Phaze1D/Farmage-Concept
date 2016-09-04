
IndexMixin = require '../../../mixins/index_mixin.coffee'
OrganizationModule = require '../../../../api/collections/organizations/organizations.coffee'

require './index.jade'

class OrganizationsIndex extends IndexMixin
  @register 'organizations.index'

  constructor: (args) ->
    super

  onRendered: ->
    super


  organizations: ->
    OrganizationModule.Organizations.find()
