faker = require 'faker'

{ chai, assert, expect } = require 'meteor/practicalmeteor:chai'
{ Meteor } = require 'meteor/meteor'
{ Accounts } = require 'meteor/accounts-base'
{ resetDatabase } = require 'meteor/xolvio:cleaner'
{ _ } = require 'meteor/underscore'

require '../../imports/api/collections/users/users.coffee'
require '../../imports/api/collections/users/server/code.coffee'

describe 'User Full App Tests Server', () ->

  beforeEach () ->
    if Meteor.isServer
      resetDatabase()

  describe 'User sign up flow', () ->
    it 'User simple schema failed validations', () ->
      doc =
        email: faker.internet.email()
        password: '12345678'

      expect( ()->
        Accounts.createUser(doc)
      ).to.Throw()

    it 'User simple schema success validations', () ->
      doc =
        email: faker.internet.email()
        profile:
          first_name: faker.name.firstName()
          last_name: faker.name.lastName()

      Accounts.createUser(doc)
