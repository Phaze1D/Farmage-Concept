faker = require 'faker'

{ chai, assert, expect } = require 'meteor/practicalmeteor:chai'
{ Meteor } = require 'meteor/meteor'
{ Accounts } = require 'meteor/accounts-base'
{ resetDatabase } = require 'meteor/xolvio:cleaner'
{ _ } = require 'meteor/underscore'

require '../../imports/api/collections/users/users.coffee'


describe 'User Full App Tests Server', () ->

  after(() ->
    resetDatabase()
  )

  describe 'User sign up flow', () ->
    it 'Check all users have only one selected organization', () ->
      Meteor.users.find().forEach (doc) ->
        count = 0
        count++ for user_organ in doc.organizations when user_organ.selected isnt false
        expect(count).to.be.at.most(1);

    it 'Testing user organizations association', () ->
      Meteor.users.find().forEach (doc) ->
        id_array = ( organization.organization_id for organization in doc.organizations )
        doc.organizations_as().forEach (doc1) ->
          expect(doc1._id in id_array).to.equal(true)

    it 'User simple schema failed validations', () ->

      doc =
        email: faker.internet.email()
        password: '12345678'

      expect(()->
        Accounts.createUser(doc)
      ).to.Throw('validation-error')


    it 'User simple schema success validations', () ->
      doc =
        email: faker.internet.email()
        profile:
          first_name: faker.name.firstName()
          last_name: faker.name.lastName()

      expect(() ->
        Accounts.createUser(doc)
      ).not.to.Throw()
