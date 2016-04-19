faker = require 'faker'

{ chai, assert, expect, should } = require 'meteor/practicalmeteor:chai'
{ Meteor } = require 'meteor/meteor'
{ _ } = require 'meteor/underscore'
{ resetDatabase } = require 'meteor/xolvio:cleaner'

{ Customers } = require '../../collections/customers/customers.coffee'

xdescribe 'Simple Customers Tests Server side', () ->

  beforeEach () ->
    resetDatabase()

  describe 'email, organization_id unique constrain', () ->
    it 'emails are same, organization_ids are different', () ->
      same_email = faker.internet.email()

      doc1 =
        first_name: faker.name.firstName()
        email: same_email
        organization_id: faker.random.uuid()

      doc2 =
        first_name: faker.name.firstName()
        email: same_email
        organization_id: faker.random.uuid()

      assert.typeOf(Customers.insert(doc1), 'string')
      assert.typeOf(Customers.insert(doc2), 'string')

      Customers.find().forEach (doc) ->
        console.log doc

    it 'emails are the same, organization_ids are the same', () ->
        same_email = faker.internet.email()
        organID = faker.random.uuid()

        doc1 =
          first_name: faker.name.firstName()
          email: same_email
          organization_id: organID

        doc2 =
          first_name: faker.name.firstName()
          email: same_email
          organization_id: organID

        assert.typeOf(Customers.insert(doc1), 'string')
        assert.typeOf(Customers.insert(doc2), 'string')

    it 'emails are null, organization_id are the same', () ->
        organID = faker.random.uuid()

        doc1 =
          first_name: faker.name.firstName()
          organization_id: organID

        doc2 =
          first_name: faker.name.firstName()
          organization_id: organID

        assert.typeOf(Customers.insert(doc1), 'string')
        assert.typeOf(Customers.insert(doc2), 'string')
