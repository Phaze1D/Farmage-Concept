faker = require 'faker'

{ chai, assert, expect } = require 'meteor/practicalmeteor:chai'
{ Meteor } = require 'meteor/meteor'
{ Accounts } = require 'meteor/accounts-base'
{ resetDatabase } = require 'meteor/xolvio:cleaner'
{ _ } = require 'meteor/underscore'

require '../../imports/api/collections/users/users.coffee'
{ Organizations } =  require '../../imports/api/collections/organizations/organizations.coffee'
{ insert, select } = require '../../imports/api/collections/organizations/methods.coffee'

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


    it 'Organizations insert validation success', (done) ->
      expect(Meteor.user()).to.exist

      organ_doc =
        name: faker.company.companyName()
        email: faker.internet.email()

      insert.call organ_doc, (err, res) ->
        expect(err).to.not.exist
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

  describe 'Organizations Select Method', ->

    it 'Organizations selected method doesnt belong', (done) ->
      expect(Meteor.user()).to.exist

      select_doc =
        organization_id: 'NONONONO'

      select.call select_doc, (err, res) ->
        expect(err).to.have.property('error', 'notAuthorized');
        done()
        return
      return

    it 'Organizations selected method belongs', (done) ->
      expect(Meteor.user()).to.exist
      select_doc =
        organization_id: Meteor.user().organizations[0].organization_id

      select.call select_doc, (err, res) ->
        expect(err).to.not.exist
        done()
        return
      return

    it 'Organizations selected method different belongs', (done) ->
      expect(Meteor.user()).to.exist
      select_doc =
        organization_id: Meteor.user().organizations[1].organization_id

      select.call select_doc, (err, res) ->
        expect(err).to.not.exist
        done()
        return
      return
