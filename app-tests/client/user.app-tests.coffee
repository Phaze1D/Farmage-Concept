faker = require 'faker'

{ chai, assert, expect } = require 'meteor/practicalmeteor:chai'
{ Meteor } = require 'meteor/meteor'
{ Accounts } = require 'meteor/accounts-base'
{ resetDatabase } = require 'meteor/xolvio:cleaner'
{ _ } = require 'meteor/underscore'

require '../../imports/api/collections/users/users.coffee'

describe 'User Full App Tests Client', () ->

  beforeEach () ->
    if Meteor.isServer
      resetDatabase()

  afterEach () ->
    Meteor.logout()

  describe 'User sign up flow', () ->
    it 'User simple schema fail validations', (done) ->


      doc =
        email: faker.internet.email()
        password: '1234568878'

      Accounts.createUser doc, (error) ->
        expect(error).to.exist
        done()

    it 'User simple schema success validations', (done) ->
      doc =
        email: faker.internet.email()
        password: '123123123'
        profile:
          first_name: faker.name.firstName()
          last_name: faker.name.lastName()

      Accounts.createUser doc, (error) ->
        expect(error).to.not.exist
        done()
