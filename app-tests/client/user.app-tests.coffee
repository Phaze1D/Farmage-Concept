faker = require 'faker'

{ chai, assert, expect } = require 'meteor/practicalmeteor:chai'
{ Meteor } = require 'meteor/meteor'
{ Accounts } = require 'meteor/accounts-base'
{ resetDatabase } = require 'meteor/xolvio:cleaner'
{ _ } = require 'meteor/underscore'

{ inviteUser } = require '../../imports/api/collections/users/methods.coffee'
require '../../imports/api/collections/users/users.coffee'


describe 'User Full App Tests Client', () ->
  before( (done) ->
    Meteor.logout( (err) ->
      done()
    )
    return
  )

  after( (done) ->
    Meteor.logout( (err) ->
      done()
    )
    return
  )

  describe 'User sign up flow', () ->

    it 'User simple schema fail validations', (done) ->
      expect(Meteor.user()).to.not.exist

      doc =
        email: faker.internet.email()
        password: '1234568878'

      Accounts.createUser doc, (err) ->
        expect(err).to.have.property('error', 'validation-error');
        done()
        return
      return

    it 'User simple schema success validations', (done) ->

      expect(Meteor.user()).to.not.exist
      doc =
        email: faker.internet.email()
        password: '123123123'
        profile:
          first_name: faker.name.firstName()
          last_name: faker.name.lastName()

      Accounts.createUser doc, (error) ->
        expect(error).to.not.exist
        done()
        return
      return

    it 'Invite nonexistent user to new organization', (done) ->


      done()
