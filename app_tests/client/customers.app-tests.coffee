faker = require 'faker'
{ chai, assert, expect } = require 'meteor/practicalmeteor:chai'
{ Meteor } = require 'meteor/meteor'
{ Accounts } = require 'meteor/accounts-base'
{ resetDatabase } = require 'meteor/xolvio:cleaner'
{ _ } = require 'meteor/underscore'

CustomerModule = require '../../imports/api/collections/customers/customers.coffee'
OrganizationModule = require '../../imports/api/collections/organizations/organizations.coffee'

{ insert, update } = require '../../imports/api/collections/customers/methods.coffee'
{
  inviteUser
} = require '../../imports/api/collections/users/methods.coffee'
OMethods = require '../../imports/api/collections/organizations/methods.coffee'


xdescribe "Customer Full App Tests Client", ->

  before( (done) ->
    Meteor.logout( (err) ->
      done()
    )
    return
  )

  after( (done) ->
    Meteor.logout( (err) ->

    )
    @timeout(20000)
    setTimeout(done, 10000)
  )


  organizationID = ''
  customerID = ''
  user1 = faker.internet.email()
  user2 = faker.internet.email()

  describe 'Customer Inserts Test', () ->

    it 'Insert not valid', (done) ->

      expect(Meteor.user()).to.not.exist

      organization_id = "NONONOOONOO"
      customer_doc =
        first_name: faker.name.firstName()
        last_name: faker.name.lastName()

      insert.call {organization_id, customer_doc}, (err, res) ->
        expect(err).to.have.property('error','validation-error')
        done()

    it 'Insert not logged in', (done) ->
      expect(Meteor.user()).to.not.exist

      organization_id = "NONONOOONOO"
      customer_doc =
        first_name: faker.name.firstName()
        last_name: faker.name.lastName()
        organization_id: organization_id

      insert.call {organization_id, customer_doc}, (err, res) ->
        expect(err).to.have.property('error','notLoggedIn')
        done()

    it 'loggedIn', (done) ->
      doc =
        email: user1
        password: '12345678'
        profile:
          first_name: faker.name.firstName()
          last_name: faker.name.lastName()

      Accounts.createUser doc, (error) ->
        expect(error).to.not.exist
        done()

    it 'Insert organ id not auth', (done) ->
      expect(Meteor.user()).to.exist

      organization_id = "NONONOOONOO"
      customer_doc =
        first_name: faker.name.firstName()
        last_name: faker.name.lastName()
        organization_id: organization_id

      insert.call {organization_id, customer_doc}, (err, res) ->
        expect(err).to.have.property('error','notAuthorized')
        done()


    it 'Create organization', (done) ->
      expect(Meteor.user()).to.exist

      organ_doc =
        name: faker.company.companyName()
        email: faker.internet.email()

      OMethods.insert.call organ_doc, (err, res) ->
        expect(err).to.not.exist
        organizationID = res
        done()

    it 'Subscribe to ', (done) ->
      callbacks =
        onStop: (err) ->
          console.log err
        onReady: () ->
          done()

      Meteor.subscribe("customers", organizationID, callbacks)

    it 'Insert customer ', (done) ->
      expect(Meteor.user()).to.exist
      expect(CustomerModule.Customers.find().count()).to.equal(0)
      organization_id = organizationID
      customer_doc =
        first_name: faker.name.firstName()
        last_name: faker.name.lastName()
        organization_id: organization_id

      insert.call {organization_id, customer_doc}, (err, res) ->
        customerID = res
        expect(CustomerModule.Customers.find().count()).to.equal(1)
        expect(err).to.not.exist
        done()


  describe 'Customers Update Tests', ->

    it 'Log Out and create new user log out again', (done) ->
      Meteor.logout((err) ->
        expect(err).to.not.exist
        doc =
          email: user2
          password: '12345678'
          profile:
            first_name: faker.name.firstName()
            last_name: faker.name.lastName()

        Accounts.createUser doc, (err) ->
          expect(err).to.not.exist
          Meteor.logout( (err) ->
            expect(err).to.not.exist
            done()
          )
      )

    it 'Login and invite user', (done) ->
      Meteor.loginWithPassword user1, '12345678', (err) ->
        expect(err).to.not.exist
        invited_user_doc =
          emails:
            [
              address: user2
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
          expect(err).to.not.exist
          done()


    it 'Log out and login with non auth user', (done) ->
      Meteor.logout( (err) ->
        expect(err).to.not.exist
        Meteor.loginWithPassword user2, '12345678', (err) ->
          expect(err).to.not.exist
          done()
      )



    it 'Is not owner or expenses_manager but belongs to organ', (done) ->
      organization_id = organizationID
      customer_id = customerID

      cus = CustomerModule.Customers.findOne()
      expect(cus.addresses.length).to.equal(0)
      customer_doc =
        addresses: [
          street: faker.address.streetName()
          city: faker.address.city()
          state: faker.address.state()
          country: faker.address.country()
          zip_code: faker.address.zipCode()
        ]

      update.call {organization_id, customer_id, customer_doc}, (err, res) ->
        expect(err).to.have.property('error', 'permissionDenied')
        done()


    it 'Log out and login with auth user', (done) ->
      Meteor.logout( (err) ->
        expect(err).to.not.exist
        Meteor.loginWithPassword user1, '12345678', (err) ->
          expect(err).to.not.exist
          done()
      )



    it 'Not valid update', (done) ->
      expect(Meteor.user()).to.exist
      expect(CustomerModule.Customers.find().count()).to.equal(1)
      organization_id = organizationID
      customer_id = "NONONO"

      customer_doc =
        last_name: () ->
          console.log "hacking"


      update.call {organization_id, customer_id, customer_doc}, (err, res) ->
        expect(err).to.have.property('error', 'validation-error')
        done()


    it 'Not auth update', (done) ->
      expect(Meteor.user()).to.exist
      expect(CustomerModule.Customers.find().count()).to.equal(1)
      organization_id = "NONONOOONOO"
      customer_id = "NONONO"

      customer_doc =
        last_name: faker.name.lastName()


      update.call {organization_id, customer_id, customer_doc}, (err, res) ->
        expect(err).to.have.property('error', 'notAuthorized')
        done()

    it 'Non existent update', (done) ->
      expect(Meteor.user()).to.exist
      expect(CustomerModule.Customers.find().count()).to.equal(1)
      organization_id = organizationID
      customer_id = "NONONO"

      customer_doc =
        last_name: faker.name.lastName()


      update.call {organization_id, customer_id, customer_doc}, (err, res) ->
        expect(err).to.have.property('error', 'notAuthorized')
        done()


    it 'Update with address success', (done) ->
      organization_id = organizationID
      customer_id = customerID

      cus = CustomerModule.Customers.findOne()
      expect(cus.addresses.length).to.equal(0)
      customer_doc =
        addresses: [
          street: faker.address.streetName()
          city: faker.address.city()
          state: faker.address.state()
          country: faker.address.country()
          zip_code: faker.address.zipCode()
        ]

      update.call {organization_id, customer_id, customer_doc}, (err, res) ->
        expect(CustomerModule.Customers.findOne().addresses.length).to.equal(1)
        done()
