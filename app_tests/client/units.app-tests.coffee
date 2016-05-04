faker = require 'faker'

{ chai, assert, expect } = require 'meteor/practicalmeteor:chai'
{ Meteor } = require 'meteor/meteor'
{ Accounts } = require 'meteor/accounts-base'
{ resetDatabase } = require 'meteor/xolvio:cleaner'
{ Random } = require 'meteor/random'
{ _ } = require 'meteor/underscore'

UnitModule = require '../../imports/api/collections/units/units.coffee'
OrganizationModule = require '../../imports/api/collections/organizations/organizations.coffee'

{
  insert
  update
} = require '../../imports/api/collections/units/methods.coffee'

{ inviteUser } = require '../../imports/api/collections/users/methods.coffee'
OMethods = require '../../imports/api/collections/organizations/methods.coffee'


describe 'Units Full App Test Client', () ->

  user1E = faker.internet.email()
  user2E = faker.internet.email()

  user1id = ""
  user2id = ""

  organizationID = ""

  createUser = (done, email) ->
    doc =
      email: email
      password: '12345678'
      profile:
        first_name: faker.name.firstName()
        last_name: faker.name.lastName()

    Accounts.createUser doc, (error) ->
      expect(error).to.not.exist
      if email is user1E
        user1id = Meteor.userId()
      else
        user2id = Meteor.userId()

      done()


  login = (done, email) ->
    Meteor.loginWithPassword email, '12345678', (err) ->
      done()

  logout = (done) ->
    Meteor.logout( (err) ->
      done()
    )

  createOrgan = (done) ->
    organ_doc =
      name: faker.company.companyName()
      email: faker.internet.email()

    OMethods.insert.call organ_doc, (err, res) ->
      organizationID = res
      expect(err).to.not.exist
      done()

  inviteUse = (done) ->


  before( (done) ->
    Meteor.logout( (err) ->
      done()
    )
    return
  )

  after( (done) ->
    Meteor.logout( (err) ->

    )
    @timeout(10000)
    setTimeout(done, 5000)
  )


  describe 'Insert Unit', () ->
    it 'create user1', (done) ->
      createUser(done, user1E)

    it 'logout', (done) ->
      logout(done)

    it 'create user2', (done) ->
      createUser(done, user2E)

    it 'logout', (done) ->
      logout(done)

    it 'Insert not valid', (done) ->
      expect(Meteor.user()).to.not.exist
      unit_doc =
        name: faker.company.companyName()
        amount: 12

      organization_id = "NONO"

      insert.call {organization_id, unit_doc}, (err, res) ->
        expect(err).to.have.property('error', 'validation-error')
        done()


    it 'Insert not logged in', (done) ->
      expect(Meteor.user()).to.not.exist
      unit_doc =
        name: faker.company.companyName()
        amount: 12
        organization_id: "NONkjhO"

      organization_id = "NONO"

      insert.call {organization_id, unit_doc}, (err, res) ->
        expect(err).to.have.property('error', 'notLoggedIn')
        done()


    it 'login', (done) ->
      login(done, user1E)

    it 'Insert not auth', (done) ->
      expect(Meteor.user()).to.exist
      unit_doc =
        name: faker.company.companyName()
        amount: 12
        organization_id: "NONkjhO"

      organization_id = "NOTAUTH"

      insert.call {organization_id, unit_doc}, (err, res) ->
        expect(err).to.have.property('error', 'notAuthorized')
        done()


    it 'create organization', (done) ->
      createOrgan(done)

    it 'Insert without permission', (done) ->
      expect(Meteor.user()).to.exist

      unit_doc =
        name: faker.company.companyName()
        amount: 12
        organization_id: "NONkjhO"

      organization_id = organizationID
      userId = user2id
      insert._execute {userId}, {organization_id, unit_doc}, (err, res) ->
        console.log err
        expect(err).to.have.property('error', 'notAuthorized')
        done()

    it 'Insert success', () ->

    it 'Insert unique name failed', () ->

    it 'Insert with non unique name but different organization', () ->

    it 'Insert with non unique name and organization', () ->


  describe 'Update Unit', () ->
    it 'Update not logged in', () ->

    it 'Update not valid', () ->

    it 'Update not auth', () ->

    it 'Update without permission', () ->

    it 'Update success', () ->

    it 'Update with same name', () ->

    it 'Update with non unique name but different organization', () ->

    it 'Update with non unique name and organization', () ->


  describe 'Insert with Parent', () ->
    it 'Insert nonexisent parent', () ->

    it 'Insert exisent parent but not to organ', () ->

    it 'Insert parent with having same ID', () ->

    it 'Insert parent success', () ->


  describe 'Update with Parent', () ->
    it 'Update nonexisent parent', () ->

    it 'Update exisent parent but not to organ', () ->

    it 'Update parent with having same ID', () ->

    it 'Update parent success', () ->
