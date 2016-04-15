faker = require 'faker'

{ chai, assert, expect } = require 'meteor/practicalmeteor:chai'
{ Meteor } = require 'meteor/meteor'
{ Accounts } = require 'meteor/accounts-base'
{ resetDatabase } = require 'meteor/xolvio:cleaner'
{ _ } = require 'meteor/underscore'

require '../users.coffee'


describe 'User Tests', () ->

  beforeEach () ->
    if Meteor.isServer
      resetDatabase()

  describe 'User sign up flow server only', () ->
    it 'User simple schema validations', () ->
      doc =
        username: faker.internet.userName()

      expect(Meteor.users.simpleSchema().namedContext().validate(doc)).to.equal(false)

    it 'Insert user manually', (done) ->
      doc =
        email: faker.internet.email()

      Meteor.users.insert( doc, (error, result) ->
        expect(error.invalidKeys).to.have.length(5)
        done()
      )
