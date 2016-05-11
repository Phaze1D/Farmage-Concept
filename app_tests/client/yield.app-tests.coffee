faker = require 'faker'

{ chai, assert, expect } = require 'meteor/practicalmeteor:chai'
{ Meteor } = require 'meteor/meteor'
{ Accounts } = require 'meteor/accounts-base'
{ resetDatabase } = require 'meteor/xolvio:cleaner'
{ Random } = require 'meteor/random'
{ _ } = require 'meteor/underscore'

UnitModule = require '../../imports/api/collections/units/units.coffee'
YieldModule = require '../../imports/api/collections/yields/yields.coffee'
OrganizationModule = require '../../imports/api/collections/organizations/organizations.coffee'

UMethods = require '../../imports/api/collections/units/methods.coffee'
OMethods = require '../../imports/api/collections/organizations/methods.coffee'

{ inviteUser } = require '../../imports/api/collections/users/methods.coffee'
{
  insert
  update
} = require '../../imports/api/collections/yields/methods.coffee'


xdescribe 'Yield Full App Test Client', () ->

  before( (done) ->
    Meteor.logout( (err) ->
      done()
    )
  )

  organizationIDs = []
  yieldIDS = []
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
      done()


  login = (done, email) ->
    Meteor.loginWithPassword email, '12345678', (err) ->
      done()

  logout = (done) ->
    Meteor.logout( (err) ->
      done()
    )

  createOrgan = (done, organizationIDs) ->
    organ_doc =
      name: faker.company.companyName()
      email: faker.internet.email()

    OMethods.insert.call organ_doc, (err, res) ->
      organizationIDs.push res
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
      editor: false
      expenses_manager: false
      sells_manager: false
      units_manager: false
      inventories_manager: true
      users_manager: false

    inviteUser.call {invited_user_doc, organization_id, permission}, (err, res) ->
      done()


  describe "Yield Insert", ->
    it "login", (done) ->
      expect(Meteor.user()).to.not.exist
      createUser(done, faker.internet.email())

    it 'create organization', (done) ->
      createOrgan(done, organizationIDs)

    it 'Subscribe to ', (done) ->
      callbacks =
        onStop: (err) ->

        onReady: () ->
          done()

      Meteor.subscribe("organizations", callbacks)

    it "Invalid Unit id", (done) ->
      yield_doc =
        name: faker.company.companyName()
        amount: 21.21
        measurement_unit: "KG"
        ingredient_name: "Eggs"
        organization_id: "nonn"

      organization_id = organizationIDs[0]

      insert.call { organization_id, yield_doc } , (err, res) ->
        expect(err).to.have.property('error', 'validation-error')
        done()

    it "Non exisent unit id", (done) ->
      yield_doc =
        name: faker.company.companyName()
        amount: 21.21
        measurement_unit: "KG"
        ingredient_name: "Eggs"
        unit_id: "andflskf"
        organization_id: "non"

      organization_id = organizationIDs[0]

      insert.call {organization_id, yield_doc} , (err, res) ->
        expect(err).to.have.property('error', 'notAuthorized')
        done()

    it 'create organization', (done) ->
      createOrgan(done, organizationIDs)


    it 'Subscribe to ', (done) ->
      callbacks =
        onStop: (err) ->

        onReady: () ->
          done()

      subHandler = Meteor.subscribe('yields', organizationIDs[1], callbacks)

    unit1d = ""
    it "create unit", (done) ->
      unit_doc =
        name: faker.company.companyName()
        amount: 12
        organization_id: "NONkjhO"

      organization_id = organizationIDs[1]

      UMethods.insert.call {organization_id, unit_doc}, (err, res) ->
        unit1d = res
        done()

    it "Exisent but not in organization unit_id", (done) ->
      yield_doc =
        name: faker.company.companyName()
        amount: 21.21
        measurement_unit: "KG"
        ingredient_name: "Eggs"
        unit_id: unit1d
        organization_id: "non"

      organization_id = organizationIDs[0]

      insert.call {organization_id, yield_doc} , (err, res) ->
        expect(err).to.have.property('error', 'notAuthorized')
        done()

    it "Valid insert", (done) ->
      yield_doc =
        name: faker.company.companyName()
        amount: 21.21
        measurement_unit: "KG"
        ingredient_name: "Eggs"
        unit_id: unit1d
        organization_id: "non"

      organization_id = organizationIDs[1]

      insert.call {organization_id, yield_doc} , (err, res) ->
        expect(err).to.not.exist
        expect(YieldModule.Yields.findOne().amount).to.equal(0)
        yieldIDS.push res
        done()



  describe "Yield Update", ->

    it "Invalid organization id", (done) ->
      yield_doc =
        name: faker.company.companyName()
        amount: 21.21

      organization_id = "noo"
      yield_id = "NONO"

      update.call {organization_id, yield_id, yield_doc} , (err, res) ->
        expect(err).to.have.property('error', 'notAuthorized')
        done()


    it "Valid yield id but not in organization", (done) ->
      yield_doc =
        name: faker.company.companyName()
        amount: 21.21

      organization_id = organizationIDs[0]
      yield_id = yieldIDS[0]

      update.call {organization_id, yield_id, yield_doc} , (err, res) ->
        expect(err).to.have.property('error', 'notAuthorized')
        done()

    it "Valid update", (done) ->
      passname = YieldModule.Yields.findOne().name

      yield_doc =
        name: faker.company.companyName()
        amount: 21.21

      organization_id = organizationIDs[1]
      yield_id = yieldIDS[0]

      update.call {organization_id, yield_id, yield_doc} , (err, res) ->
        expect(YieldModule.Yields.findOne().name).to.not.equal(passname)
        expect(YieldModule.Yields.findOne().amount).to.equal(0)
        done()
