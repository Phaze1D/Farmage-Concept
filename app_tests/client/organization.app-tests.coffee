faker = require 'faker'

{ chai, assert, expect } = require 'meteor/practicalmeteor:chai'
{ Meteor } = require 'meteor/meteor'
{ Accounts } = require 'meteor/accounts-base'
{ resetDatabase } = require 'meteor/xolvio:cleaner'
{ _ } = require 'meteor/underscore'

{
  insert
  updateNameAndEmail
  addAddress
  deleteAddress
  addTelephone
  deleteTelephone
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

    it 'Organizations insert validation unqiue name should fail', (done) ->
      expect(Meteor.user()).to.exist

      organ_doc =
        name: sharedName
        email: faker.internet.email()

      insert.call organ_doc, (err, res) ->
        expect(err).to.have.property('error', 'nameNotUnique')
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



  describe 'Organizations Update Name/Email', () ->
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

      updateNameAndEmail.call {organization_id, updated_organization_doc}, (err, res) ->
        expect(err).to.have.property('error', 'notAuthorized')
        done()



    it 'Update same organization with same name', (done) ->

      organization_id = organization._id
      updated_organization_doc =
        name: organization.name
        email: faker.internet.email()

      updateNameAndEmail.call {organization_id, updated_organization_doc}, (err, res) ->
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

    it ' Update organizations unique name failed', (done) ->
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

      updateNameAndEmail.call {organization_id, updated_organization_doc}, (err, res) ->
        expect(err).to.have.property('error', 'nameNotUnique')
        done()

    it 'Update organization name and email success', (done) ->
      organization2 = Organizations.findOne()

      organization_id = organization2._id
      updated_organization_doc =
        name: faker.company.companyName()
        email: faker.internet.email()

      updateNameAndEmail.call {organization_id, updated_organization_doc}, (err, res) ->
        expect(err).to.not.exist
        expect(organization2.name).to.not.equal(Organizations.findOne().name)
        expect(organization2.email).to.not.equal(Organizations.findOne().email)
        done()



  xdescribe 'Organizations add address', () ->

    shared_address_doc =
      name: 'home'
      street: faker.address.streetAddress()
      city: faker.address.city()
      state: faker.address.state()
      zip_code: faker.address.zipCode()
      country: faker.address.country()

    it 'Invalid address', (done) ->
      organization_id = Organizations.findOne()._id

      address_doc =
        name: 'home'
        street2: faker.address.streetAddress()
        city: faker.address.city()
        state: faker.address.state()
        zip_code: faker.address.zipCode()
        country: faker.address.country()

      addAddress.call {organization_id, address_doc}, (err, res) ->
        expect(err).to.have.property('error', 'validation-error')
        done()

    it 'Valid address', (done) ->

      organization2 = Organizations.findOne()
      expect(organization2.addresses.length).to.equal(0)
      organization_id = organization2._id

      address_doc = shared_address_doc

      addAddress.call {organization_id, address_doc}, (err, res) ->
        expect(err).to.not.exist
        expect(Organizations.findOne().addresses.length).to.equal(1)
        done()

    it 'Duplicate address', (done) ->

      organization2 = Organizations.findOne()
      expect(organization2.addresses.length).to.equal(1)
      organization_id = organization2._id

      address_doc = shared_address_doc

      addAddress.call {organization_id, address_doc}, (err, res) ->
        expect(err).to.not.exist
        expect(Organizations.findOne().addresses.length).to.equal(1)
        done()



  xdescribe 'Organizations remove address', () ->

    it 'Remove nonexistent address', (done) ->
      organization2 = Organizations.findOne()
      expect(organization2.addresses.length).to.equal(1)
      organization_id = organization2._id

      address_doc =
          name: 'home'
          street: faker.address.streetAddress()
          city: faker.address.city()
          state: faker.address.state()
          zip_code: faker.address.zipCode()
          country: faker.address.country()

      deleteAddress.call {organization_id, address_doc}, (err, res) ->
        expect(err).to.not.exist
        expect(Organizations.findOne().addresses.length).to.equal(1)
        done()

    it 'Remove existent address', (done) ->
      organization2 = Organizations.findOne()
      expect(organization2.addresses.length).to.equal(1)
      organization_id = organization2._id

      address_doc = organization2.addresses[0]

      deleteAddress.call {organization_id, address_doc}, (err, res) ->
        expect(err).to.not.exist
        expect(Organizations.findOne().addresses.length).to.equal(0)
        done()



  xdescribe ' Organizations add telephones', () ->

    shared_telephone =
      name: 'Home Number'
      number: faker.phone.phoneNumber()

    it 'Invalid telephone', (done) ->
      organization_id = Organizations.findOne()._id

      telephone_doc =
        name: faker.name.firstName()
        number: 'REallladsfLOngNumberasdThatisnotok'


      addTelephone.call {organization_id, telephone_doc}, (err, res) ->
        expect(err).to.have.property('error', 'validation-error')
        done()

    it 'Valid telephone', (done) ->

      organization2 = Organizations.findOne()
      expect(organization2.telephones.length).to.equal(0)
      organization_id = organization2._id

      telephone_doc = shared_telephone

      addTelephone.call {organization_id, telephone_doc}, (err, res) ->
        expect(err).to.not.exist
        expect(Organizations.findOne().telephones.length).to.equal(1)
        done()

    it 'Duplicate telephones', (done) ->

      organization2 = Organizations.findOne()
      expect(organization2.telephones.length).to.equal(1)
      organization_id = organization2._id

      telephone_doc = shared_telephone

      addTelephone.call {organization_id, telephone_doc}, (err, res) ->
        expect(err).to.not.exist
        expect(Organizations.findOne().telephones.length).to.equal(1)
        done()


  xdescribe 'Organizations remove telephones', () ->

    it 'Remove nonexistent telephones', (done) ->
      organization2 = Organizations.findOne()
      expect(organization2.telephones.length).to.equal(1)
      organization_id = organization2._id

      telephone_doc =
        name: faker.name.firstName()
        number: faker.phone.phoneNumber()

      deleteTelephone.call {organization_id, telephone_doc}, (err, res) ->
        expect(err).to.not.exist
        expect(Organizations.findOne().telephones.length).to.equal(1)
        done()

    it 'Remove existent telephone', (done) ->
      organization2 = Organizations.findOne()
      expect(organization2.telephones.length).to.equal(1)
      organization_id = organization2._id

      telephone_doc = organization2.telephones[0]

      deleteTelephone.call {organization_id, telephone_doc}, (err, res) ->
        expect(err).to.not.exist
        expect(Organizations.findOne().telephones.length).to.equal(0)
        done()
