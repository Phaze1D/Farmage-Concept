faker = require 'faker'
{ chai, assert, expect } = require 'meteor/practicalmeteor:chai'
{ Meteor } = require 'meteor/meteor'
{ Accounts } = require 'meteor/accounts-base'
{ resetDatabase } = require 'meteor/xolvio:cleaner'
{ _ } = require 'meteor/underscore'


OrganizationModule = require '../../imports/api/collections/organizations/organizations.coffee'
ProductModule = require '../../imports/api/collections/products/products.coffee'

{
  insert
  update
} = require '../../imports/api/collections/products/methods.coffee'

{ inviteUser } = require '../../imports/api/collections/users/methods.coffee'
OMethods = require '../../imports/api/collections/organizations/methods.coffee'

xdescribe 'Product Full App Test Client', () ->

  createUser = (done, email) ->
    doc =
      email: email
      password: '12345678'
      profile:
        first_name: faker.name.firstName()
        last_name: faker.name.lastName()

    Accounts.createUser doc, (error) ->
      done()

  login = (done, email) ->
    Meteor.loginWithPassword email, '12345678', (err) ->
      done()

  logout = (done) ->
    Meteor.logout( (err) ->
      done()
    )

  organizationID = ""

  createOrgan = (done) ->
    organ_doc =
      name: faker.company.companyName()
      email: faker.internet.email()

    OMethods.insert.call organ_doc, (err, res) ->
      organizationID = res
      expect(err).to.not.exist
      done()

  describe 'Product Insert', () ->

    it 'create user', (done) ->
      createUser done, faker.internet.email()

    it 'SKU Validation Invalid 1', (done) ->
      product_doc =
        name: "Cake"
        sku: "NOT Valid"
        unit_price: 12.21
        currency: "MXN"
        tax_rate: 10

      organization_id = "NONONONON"

      insert.call {organization_id, product_doc}, (err, res) ->
        expect(err).to.have.property('error', 'regExError')
        done()

    it 'SKU Validation Invalid 2', (done) ->
      product_doc =
        name: "Cake"
        sku: "NOTValid--  9-- 9"
        unit_price: 12.21
        currency: "MXN"
        tax_rate: 10

      organization_id = "NONONONcON"

      insert.call {organization_id, product_doc}, (err, res) ->
        expect(err).to.have.property('error', 'regExError')
        done()

    it 'Create Organ', (done) ->
      createOrgan(done)

    it 'Subscribe to ', (done) ->
      callbacks =
        onStop: (err) ->

        onReady: () ->
          done()

      subHandler = Meteor.subscribe("products", organizationID, callbacks)

    it 'SKU Validation Valid', (done) ->
      product_doc =
        name: "Cake"
        sku: "NOTalid090"
        unit_price: 12.21
        currency: "MXN"
        tax_rate: 10
        ingredients: [
          ingredient_name: faker.name.firstName()
          amount: 123.123
          measurement_unit: "KG"
        ]
        organization_id: "NONO"

      organization_id = organizationID

      insert.call {organization_id, product_doc}, (err, res) ->
        expect(err).to.not.exist
        done()


    it 'SKU unique name invalid', (done) ->
      product_doc =
        name: "Cake"
        sku: "NOTalid090"
        unit_price: 12.21
        currency: "MXN"
        tax_rate: 10
        ingredients: [
          ingredient_name: faker.name.firstName()
          amount: 123.123
          measurement_unit: "KG"
        ]
        organization_id: "NONO"

      organization_id = organizationID

      insert.call {organization_id, product_doc}, (err, res) ->
        expect(err).to.have.property('error','skuNotUnique')
        done()

    it 'SKU unique name valid', (done) ->
      product_doc =
        name: "Cake"
        sku: "NOTAlid090"
        unit_price: 12.21
        currency: "MXN"
        tax_rate: 10
        ingredients: [
          ingredient_name: faker.name.firstName()
          amount: 123.123
          measurement_unit: "KG"
        ]
        organization_id: "NONO"

      organization_id = organizationID

      insert.call {organization_id, product_doc}, (err, res) ->
        expect(err).to.not.exist
        done()

    it 'Search Text', () ->

      expect(ProductModule.Products.find({ sku: { $regex: /^NOTA/i } }).count()).to.equal(2)
      expect(ProductModule.Products.find({ sku: { $regex: /^NOTAadsf/i } }).count()).to.equal(0)


    it 'Checking ingredient autoValue', (done) ->
      inmame = faker.name.firstName()
      mu = faker.company.companyName()
      product_doc =
        name: "Cake"
        sku: "NOTAlid-90-()"
        unit_price: 12.21
        currency: "MXN"
        tax_rate: 10
        ingredients: [
          {ingredient_name: inmame
          amount: 123.123
          measurement_unit: mu}
        ]
        organization_id: "NONO"

      organization_id = organizationID
      insert.call {organization_id, product_doc}, (err, res) ->
        expect(ProductModule.Products.findOne(res).ingredients[0].ingredient_name).to.not.equal(inmame)
        expect(ProductModule.Products.findOne(res).ingredients[0].measurement_unit).to.not.equal(mu)
        done()


  describe 'Product Update', () ->

    it 'SKU Validation', (done) ->
      product_doc =
        name: "Cake"
        sku: "NOT Valid"
        unit_price: 12.21
        currency: "MXN"
        tax_rate: 10

      organization_id = organizationID

      product_id = ProductModule.Products.findOne()._id

      update.call {organization_id, product_id, product_doc}, (err, res) ->
        expect(err).to.have.property('error', 'regExError')
        done()

    it 'SKU unique name failed', (done) ->
      product_doc =
        name: "Cake"
        sku: "NOTAlid090"
        unit_price: 12.21
        currency: "MXN"
        tax_rate: 10
        organization_id: "NONO"

      organization_id = organizationID

      product_id = ProductModule.Products.findOne()._id

      update.call {organization_id, product_id, product_doc}, (err, res) ->
        expect(err).to.have.property('error', 'skuNotUnique')
        done()

    it 'Ingredient validation', (done) ->
      product_doc =
        name: "Cake"
        sku: "NOTalid090"
        unit_price: 12.21
        currency: "MXN"
        tax_rate: 10
        ingredients: [
          ingredient_name: faker.name.firstName()
          amount: 123.123
          measurement_unit: "KG"
        ]
        organization_id: "NONO"

      organization_id = organizationID

      product_id = ProductModule.Products.findOne()._id

      update.call {organization_id, product_id, product_doc}, (err, res) ->
        expect(err).to.have.property('reason', 'ingredients cannot be set during an update')
        done()
