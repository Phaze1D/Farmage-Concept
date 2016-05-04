faker = require 'faker'

{ chai, assert, expect } = require 'meteor/practicalmeteor:chai'
{ Meteor } = require 'meteor/meteor'
{ Accounts } = require 'meteor/accounts-base'
{ resetDatabase } = require 'meteor/xolvio:cleaner'
{ _ } = require 'meteor/underscore'

{ Organizations } = require '../../imports/api/collections/organizations/organizations.coffee'



describe 'User Full App Tests Server', () ->

  after(() ->
    resetDatabase()
  )

  describe 'User sign up flow', () ->

    it 'Testing user organizations association', () ->
      
      Meteor.users.find().forEach (doc) ->
        doc.organizations().forEach (doc2) ->
          id_array = ( user.user_id for user in doc2.ousers )
          expect(doc._id in id_array).to.equal(true)



    it 'Testing user does not have duplicate organizations', () ->
      Meteor.users.find().forEach (doc) ->
        doc.organizations().forEach (doc2) ->
          count = 0
          for user in doc2.ousers
            if user.user_id is doc._id
              count++
          expect(count).to.be.at.most(1)

    it 'User simple schema failed validations', () ->
      doc =
        email: faker.internet.email()
        password: '12345678'

      expect(()->
        Accounts.createUser(doc)
      ).to.Throw('validation-error')

      return


    it 'User simple schema success validations', () ->
      doc =
        email: faker.internet.email()
        profile:
          first_name: faker.name.firstName()
          last_name: faker.name.lastName()

      expect(() ->
        Accounts.createUser(doc)
      ).not.to.Throw()

      return
