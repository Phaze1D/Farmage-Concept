
faker = require 'faker'

{ chai, assert, expect } = require 'meteor/practicalmeteor:chai'
{ Meteor } = require 'meteor/meteor'
{ resetDatabase } = require 'meteor/xolvio:cleaner'
{ _ } = require 'meteor/underscore'

{ Organizations } = require '../../collections/organizations/organizations.coffee'

xdescribe 'Simple Organizations Tests Server Side', () ->

  beforeEach () ->
    resetDatabase()

  describe 'validations', () ->
    it 'validates valid without contact info', () ->
      doc =
        name: faker.company.companyName()

      expect(Organizations.simpleSchema().namedContext().validate(doc)).to.equal(true)
      expect(Organizations.simpleSchema().namedContext().invalidKeys()).to.have.length(0)


    it 'validate invalid without contact info', () ->
      doc =
        name: faker.lorem.paragraphs()

      expect(Organizations.simpleSchema().namedContext().validate(doc)).to.equal(false)
      expect(Organizations.simpleSchema().namedContext().invalidKeys()).to.have.length(1)
      expect(Organizations.simpleSchema().namedContext().invalidKeys()[0].type).to.equal('maxString')

    it 'validate valid with contact info', () ->
      doc =
        name: faker.company.companyName()
        email: faker.internet.email()
        addresses:[
          street: faker.address.streetAddress()
          city: faker.address.city()
          state: faker.address.state()
          zip_code: faker.address.zipCode()
          country: faker.address.country()
        ]

      expect(Organizations.simpleSchema().namedContext().validate(doc)).to.equal(true)
      expect(Organizations.simpleSchema().namedContext().invalidKeys()).to.have.length(0)


  describe 'insert', () ->
    # expect(false).to.equal(true)

  describe 'upsert', () ->
    # expect(false).to.equal(true)

  describe 'update', () ->
    # expect(false).to.equal(true)

  describe 'remove', () ->
    # expect(false).to.equal(true)
