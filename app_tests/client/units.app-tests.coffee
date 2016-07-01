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


xdescribe 'Units Full App Test Client', () ->

  user1E = faker.internet.email()
  user2E = faker.internet.email()

  user1id = ""
  user2id = ""

  organizationID = ""
  oldOrgan = ""

  unit1N = faker.company.companyName()
  unit2N = faker.company.companyName()

  unit1id = ""
  unit2id = ""

  subHandler = ""


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

  inviteUse = (done, email) ->
    invited_user_doc =
      emails:
        [
          address: email
        ]
      profile:
        first_name: faker.name.firstName()

    organization_id = organizationID

    permission =
      owner: false
      viewer: false
      expenses_manager: false
      sells_manager: false
      units_manager: false
      inventories_manager: true
      users_manager: false

    inviteUser.call {invited_user_doc, organization_id, permission}, (err, res) ->
      done()


  describe 'Insert Unit', () ->
    before( (done) ->
      Meteor.logout()
      @timeout(10000)
      setTimeout(done, 5000)
      return
    )

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

    it 'Subscribe to ', (done) ->
      callbacks =
        onStop: (err) ->

        onReady: () ->
          done()

      subHandler = Meteor.subscribe("units", organizationID, callbacks)

    it 'Insert without permission and not in ousers', () ->
      expect(Meteor.user()).to.exist
      unit_doc =
        name: faker.company.companyName()
        amount: 12
        organization_id: organizationID

      organization_id = organizationID
      userId = user2id
      expect( () ->
        insert._execute {userId}, {organization_id, unit_doc}
      ).to.Throw('notAuthorized')


    it 'invite user', (done) ->
      inviteUse(done, user2E)

    it 'login user2', (done) ->
      login(done, user2E)

    it 'Insert without permission and in ousers', (done) ->
      expect(Meteor.user()).to.exist

      unit_doc =
        name: faker.company.companyName()
        amount: 12
        organization_id: organizationID

      organization_id = organizationID
      userId = user2id

      insert.call {organization_id, unit_doc}, (err, res) ->
        expect(err).to.have.property('error','permissionDenied')
        done()


    it 'logout', (done) ->
      logout(done)

    it 'login user1', (done) ->
      login(done, user1E)

    it 'Insert success', (done) ->
      expect(Meteor.user()).to.exist
      unit_doc =
        name: unit1N
        amount: 12
        organization_id: organizationID

      organization_id = organizationID

      insert.call {organization_id, unit_doc}, (err, res) ->
        expect(UnitModule.Units.findOne().amount).to.equal(0)
        expect(err).to.not.exist
        unit1id = res
        done()


    it 'create organization', (done) ->
      oldOrgan = organizationID
      createOrgan(done)

    it 'Subscribe to ', (done) ->
      subHandler.stop()
      callbacks =
        onStop: (err) ->

        onReady: () ->
          done()

      subHandler = Meteor.subscribe("units", organizationID, callbacks)

    it 'Insert with same name but different organization', (done) ->
      expect(UnitModule.Units.find().count()).to.equal(0)
      expect(Meteor.user()).to.exist
      unit_doc =
        name: unit1N
        amount: 12
        organization_id: organizationID

      organization_id = organizationID

      insert.call {organization_id, unit_doc}, (err, res) ->
        unit2id = res
        expect(UnitModule.Units.findOne().amount).to.equal(0)
        expect(err).to.not.exist
        done()


    it 'Insert with same name and organization', (done) ->
      expect(UnitModule.Units.find().count()).to.equal(1)
      expect(Meteor.user()).to.exist

      unit_doc =
        name: unit1N
        amount: 12
        organization_id: oldOrgan

      organization_id = oldOrgan

      insert.call {organization_id, unit_doc}, (err, res) ->
        expect(UnitModule.Units.find().count()).to.equal(1)
        expect(err).to.have.property('error','nameNotUnique')
        subHandler.stop()
        done()


  describe 'Update Unit', () ->
    before( (done) ->
      Meteor.logout()
      @timeout(10000)
      setTimeout(done, 5000)
      return
    )

    it 'Update not logged in', (done) ->
      expect(Meteor.user()).to.not.exist
      unit_doc =
        description: faker.lorem.sentence()
        amount: 12

      organization_id = "NONO"

      unit_id = unit1id

      update.call {organization_id, unit_id, unit_doc}, (err, res) ->
        expect(err).to.have.property('error', 'notLoggedIn')
        done()

    it 'login', (done) ->
      login(done, user1E)

    it 'Update not valid', (done) ->
      expect(Meteor.user()).to.exist
      unit_doc =
        description: faker.lorem.paragraphs()
        amount: 12

      organization_id = "NONO"

      unit_id = unit1id

      update.call {organization_id, unit_id, unit_doc}, (err, res) ->
        expect(err).to.have.property('error', 'validation-error')
        done()


    it 'Update not auth', (done) ->
      expect(Meteor.user()).to.exist
      unit_doc =
        description: faker.lorem.sentence()
        amount: 12

      organization_id = "NONO"

      unit_id = unit1id

      update.call {organization_id, unit_id, unit_doc}, (err, res) ->
        expect(err).to.have.property('error', 'notAuthorized')
        done()

    it 'Update without permission ', () ->
      expect(Meteor.user()).to.exist

      unit_doc =
        name: faker.company.companyName()
        amount: 12
        organization_id: "NONkjhO"

      organization_id = oldOrgan
      unit_id = unit1id
      userId = user2id

      expect( () ->
        update._execute {userId}, {organization_id, unit_id, unit_doc}
      ).to.Throw('notAuthorized')

    it 'Update does not belong', (done) ->
      unit_doc =
        description: faker.lorem.sentence()
        amount: 12

      organization_id = organizationID

      unit_id = unit1id

      update.call {organization_id, unit_id, unit_doc}, (err, res) ->
        expect(err).to.have.property('error', 'notAuthorized')
        done()

    it 'Subscribe to ', (done) ->
      callbacks =
        onStop: (err) ->

        onReady: () ->
          done()

      subHandler = Meteor.subscribe("units", oldOrgan, callbacks)


    it 'Update with same name', (done) ->
      expect(UnitModule.Units.find().count()).to.equal(1)
      expect(UnitModule.Units.findOne().description).to.not.exist
      unit_doc =
        name: UnitModule.Units.findOne().name
        description: faker.lorem.sentence()
        amount: 12

      organization_id = oldOrgan

      unit_id = unit1id

      update.call {organization_id, unit_id, unit_doc}, (err, res) ->
        expect(err).to.not.exist
        expect(UnitModule.Units.findOne().amount).to.equal(0)
        expect(UnitModule.Units.findOne().description).to.exist
        done()

    it 'Update success', (done) ->
      expect(UnitModule.Units.find().count()).to.equal(1)
      unit1N = faker.name.firstName()
      unit_doc =
        description: faker.lorem.sentence()
        amount: 12

      organization_id = oldOrgan

      unit_id = unit1id

      update.call {organization_id, unit_id, unit_doc}, (err, res) ->
        expect(err).to.not.exist
        expect(UnitModule.Units.findOne().amount).to.equal(0)
        expect(UnitModule.Units.findOne().description).to.exist
        done()

    it 'Update with same name but different organization', (done) ->
      expect(UnitModule.Units.find().count()).to.equal(1)
      unit1N = unit2N
      unit_doc =
        name: unit1N
        description: faker.lorem.sentence()
        amount: 12

      organization_id = oldOrgan

      unit_id = unit1id

      update.call {organization_id, unit_id, unit_doc}, (err, res) ->
        expect(err).to.not.exist
        expect(UnitModule.Units.findOne().amount).to.equal(0)
        done()


    sn2 = faker.name.firstName()
    it 'Insert success', (done) ->
      expect(Meteor.user()).to.exist
      unit_doc =
        name: sn2
        amount: 12
        organization_id: oldOrgan

      organization_id = oldOrgan

      insert.call {organization_id, unit_doc}, (err, res) ->
        expect(err).to.not.exist
        done()

    it 'Update with same name and organization', (done) ->
      expect(UnitModule.Units.find().count()).to.equal(2)
      unit_doc =
        name: sn2
        description: faker.lorem.sentence()
        amount: 12

      organization_id = oldOrgan

      unit_id = unit1id

      update.call {organization_id, unit_id, unit_doc}, (err, res) ->
        expect(err).to.have.property('error', 'nameNotUnique')
        done()

  describe 'Insert with Parent', () ->
    it 'Insert nonexisent parent', (done) ->
      expect(Meteor.user()).to.exist
      unit_doc =
        name: faker.name.firstName()
        amount: 12
        organization_id: oldOrgan
        unit_id: "nononon"

      organization_id = oldOrgan

      insert.call {organization_id, unit_doc}, (err, res) ->
        expect(err).to.have.property('error','notAuthorized')
        done()

    it 'Insert exisent parent but not to organ', (done) ->
      expect(Meteor.user()).to.exist
      unit_doc =
        name: faker.name.firstName()
        amount: 12
        organization_id: oldOrgan
        unit_id: unit2id

      organization_id = oldOrgan

      insert.call {organization_id, unit_doc}, (err, res) ->
        expect(err).to.have.property('error','notAuthorized')
        done()

    it 'Insert parent success', (done) ->
      expect(Meteor.user()).to.exist
      unit_doc =
        name: faker.name.firstName()
        amount: 12
        organization_id: organizationID
        unit_id: unit2id

      organization_id = organizationID

      insert.call {organization_id, unit_doc}, (err, res) ->
        expect(err).to.not.exist
        done()


  describe 'Update with Parent', () ->
    it 'Update nonexisent parent', (done) ->
      unit_doc =
        description: faker.lorem.sentence()
        amount: 12
        unit_id: "nonnono"

      organization_id = oldOrgan

      unit_id = unit1id

      update.call {organization_id, unit_id, unit_doc}, (err, res) ->
        expect(err).to.have.property('error','notAuthorized')
        done()

    it 'Update exisent parent but not to organ', (done) ->
      unit_doc =
        description: faker.lorem.sentence()
        amount: 12
        unit_id: unit2id

      organization_id = oldOrgan

      unit_id = unit1id

      update.call {organization_id, unit_id, unit_doc}, (err, res) ->
        expect(err).to.have.property('error','notAuthorized')
        done()

    it 'Update parent with having same ID', (done) ->
      unit_doc =
        description: faker.lorem.sentence()
        amount: 12
        unit_id: unit1id

      organization_id = oldOrgan

      unit_id = unit1id

      update.call {organization_id, unit_id, unit_doc}, (err, res) ->
        expect(err).to.have.property('error','loopError')
        done()

    it 'Update parent success', (done) ->

      unit_doc =
        description: faker.lorem.sentence()
        amount: 12
        unit_id: UnitModule.Units.findOne(_id: {$ne: unit1id})._id

      organization_id = oldOrgan

      unit_id = unit1id

      update.call {organization_id, unit_id, unit_doc}, (err, res) ->
        expect(UnitModule.Units.findOne(_id: unit1id).unit_id).to.exist
        expect(err).to.not.exist
        done()
