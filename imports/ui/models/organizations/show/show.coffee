ShowMixin = require '../../../mixins/show_mixin.coffee'
require './show.jade'

class OrganizationShow extends ShowMixin
  @register 'OrganizationShow'

  constructor: (args) ->
    super

  onCreated: ->
    super

  onRendered: ->
    super
    @parentComponent().parentComponent().parentComponent().rightData.set
      update_id: @data().organization._id

  tabs: ->
    ['Information', 'Analytics', 'Reports']

  founder:  ->
    Meteor.users.findOne @data().organization.founder().user_id

  email: ->
    @founder().emails[0].address

  addresses: ->
    if @data().organization.addresses.length > 0
      @data().organization.addresses

  telephones: ->
    if @data().organization.telephones.length > 0
      @data().organization.telephones
