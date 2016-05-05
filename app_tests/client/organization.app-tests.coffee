faker = require 'faker'

{ chai, assert, expect } = require 'meteor/practicalmeteor:chai'
{ Meteor } = require 'meteor/meteor'
{ Accounts } = require 'meteor/accounts-base'
{ resetDatabase } = require 'meteor/xolvio:cleaner'
{ _ } = require 'meteor/underscore'

{
  insert
  update
} = require '../../imports/api/collections/organizations/methods.coffee'

{ Organizations } = require '../../imports/api/collections/organizations/organizations.coffee'

xdescribe 'Organizations Full App Tests Client', () ->

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


    it 'Organizations insert not logged in', () ->
      expect(Meteor.user()).to.not.exist

      doc =
        name: faker.company.companyName()
        email: faker.internet.email()

      expect ->
        insert.call(doc)
      .to.Throw('notLoggedIn')
      return

    it 'Login', (done) ->
      doc =
        email: faker.internet.email()
        password: '123123123'
        profile:
          first_name: faker.name.firstName()
          last_name: faker.name.lastName()

      Accounts.createUser doc, (error) ->
        expect(error).not.to.exist
        done()


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

    it 'Organizations insert validation unqiue name should not fail', (done) ->
      expect(Meteor.user()).to.exist

      organ_doc =
        name: sharedName
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



  describe 'Organizations Update Info', () ->
    organization = ''

    before( (done) ->
      callbacks =
        onStop: () ->
        onReady: () ->
          organization = Organizations.findOne()
          done()

      Meteor.subscribe("organizations", callbacks)
    )

    it 'Update unauth organization', (done) ->
      expect(Meteor.user()).to.exist

      organization_id = "IDONTOWNTHIS"
      updated_organization_doc =
        name: faker.company.companyName()
        email: faker.internet.email()

      update.call {organization_id, updated_organization_doc}, (err, res) ->
        expect(err).to.have.property('error', 'notAuthorized')
        done()



    it 'Update same organization with same name', (done) ->

      organization_id = organization._id
      updated_organization_doc =
        name: organization.name
        email: faker.internet.email()

      update.call {organization_id, updated_organization_doc}, (err, res) ->
        expect(err).to.not.exist
        done()

    it 'Subscribe organizations logging out user', (done) ->
      Meteor.logout( (err) ->
        expect(Organizations.find().count()).to.equal(0)
        done()
      )

    it 'Subscribe organizations logging in user', (done) ->
      expect(Meteor.user()).to.not.exist
      doc =
        email: faker.internet.email()
        password: '123123123'
        profile:
          first_name: faker.name.firstName()
          last_name: faker.name.lastName()

      Accounts.createUser doc, (error) ->
        expect(error).to.not.exist
        expect(Organizations.find().count()).to.equal(0)
        done()

    it ' Update organizations unique name not failed', (done) ->
      expect(Meteor.user()).to.exist

      organ_doc =
        name: faker.company.companyName()
        email: faker.internet.email()

      insert.call organ_doc

      organization2 = Organizations.findOne()

      expect(organization2.name).to.not.equal(organization.name)

      organization_id = organization2._id
      updated_organization_doc =
        name: organization.name
        email: faker.internet.email()

      update.call {organization_id, updated_organization_doc}, (err, res) ->
        expect(err).to.not.exist
        done()

    it 'Update organization name and email success', (done) ->
      organization2 = Organizations.findOne()

      organization_id = organization2._id
      updated_organization_doc =
        name: faker.company.companyName()
        email: faker.internet.email()

      update.call {organization_id, updated_organization_doc}, (err, res) ->
        expect(err).to.not.exist
        expect(organization2.name).to.not.equal(Organizations.findOne().name)
        expect(organization2.email).to.not.equal(Organizations.findOne().email)
        done()


    it 'Update organization with telephone', (done) ->
      organization2 = Organizations.findOne()

      organization_id = organization2._id
      updated_organization_doc =
        name: faker.company.companyName()
        email: faker.internet.email()
        telephones: [
          name: "Name"
          number: faker.phone.phoneNumber()
        ]

      update.call {organization_id, updated_organization_doc}, (err, res) ->
        expect(err).to.not.exist
        expect(Organizations.findOne().telephones.length).to.be.at.least(1)
        done()
