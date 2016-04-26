faker = require 'faker'

{ chai, assert, expect } = require 'meteor/practicalmeteor:chai'
{ Meteor } = require 'meteor/meteor'
{ Accounts } = require 'meteor/accounts-base'
{ resetDatabase } = require 'meteor/xolvio:cleaner'
{ _ } = require 'meteor/underscore'

{ insert } = require '../../imports/api/collections/organizations/methods.coffee'

describe 'Organizations Full App Tests Client', () ->

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

  describe 'Organizations Insert Method', () ->

    it 'Organization insert failed validation', () ->
      expect(Meteor.user()).to.not.exist
      organ =
        email: faker.internet.email()

      expect ->
        insert.call organ
      .to.Throw('validation-error')
      return


    it 'Organizations insert not logged in', (done) ->
      expect(Meteor.user()).to.not.exist

      doc =
        name: faker.company.companyName()
        email: faker.internet.email()

      expect ->
        insert.call(doc)
      .to.Throw('notLoggedIn')

      doc =
        email: faker.internet.email()
        password: '123123123'
        profile:
          first_name: faker.name.firstName()
          last_name: faker.name.lastName()

      Accounts.createUser doc, (error) ->
        expect(error).not.to.exist
        done()
        return
      return

    sharedName = faker.company.companyName()
    it 'Organizations insert validation success', (done) ->
      expect(Meteor.user()).to.exist

      organ_doc =
        name: sharedName
        email: faker.internet.email()

      insert.call organ_doc, (err, res) ->

        expect(err).to.not.exist
        done()
        return
      return

    it 'Organizations insert validation unqiue name should fail', (done) ->
      expect(Meteor.user()).to.exist

      organ_doc =
        name: sharedName
        email: faker.internet.email()

      insert.call organ_doc, (err, res) ->
        expect(err).to.have.property('error', 'nameNotUnqiue')
        done()
        return
      return

    it 'Organizations insert second', (done) ->
      expect(Meteor.user()).to.exist

      organ_doc =
        name: faker.company.companyName()
        email: faker.internet.email()

      insert.call organ_doc, (err, res) ->
        expect(err).to.not.exist
        done()
        return
      return

    it 'Organizations insert third', (done) ->
      expect(Meteor.user()).to.exist

      organ_doc =
        name: faker.company.companyName()
        email: faker.internet.email()

      insert.call organ_doc, (err, res) ->

        expect(err).to.not.exist

        done()
        return
      return
