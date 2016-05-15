faker = require 'faker'

{ chai, assert, expect } = require 'meteor/practicalmeteor:chai'
{ Meteor } = require 'meteor/meteor'
{ Accounts } = require 'meteor/accounts-base'
{ resetDatabase } = require 'meteor/xolvio:cleaner'
{ Random } = require 'meteor/random'
{ _ } = require 'meteor/underscore'

UnitModule = require '../../imports/api/collections/units/units.coffee'
EventModule = require '../../imports/api/collections/events/events.coffee'

EMethods = require '../../imports/api/collections/events/methods.coffee'
OMethods = require '../../imports/api/collections/organizations/methods.coffee'
UMethods = require '../../imports/api/collections/units/methods.coffee'
YMethods = require '../../imports/api/collections/yields/methods.coffee'
PMethods = require '../../imports/api/collections/products/methods.coffee'
IMethods = require '../../imports/api/collections/inventories/methods.coffee'


organizationIDs = []
yieldIDs = []
unitIDs = []
productIDs = []
inventoryIDS = []
ingredients = []


describe "Events Client Side Test", ->

  before ->
    resetDatabase(null);

  describe "Setup", ->
    it "Create User", (done) ->
      createUser(done, faker.internet.email())

    it "Create Organization", (done) ->
      createOrgan(done)

    it "Create Unit", (done) ->
      createUnit(done)

    it "Create Yield", (done) ->
      createYield(done)

    it "Create Product", (done) ->
      ings = [ingredients[0]]
      createProduct(done, ings)

    it "Create Inventory", (done) ->
      createInventory(done, 0)

    it "Subscribe to units", (done) ->
      subscribe(done, 'units')

    it "Subscribe to events", (done) ->
      subscribe(done, 'events')




  describe "User Event Tests", ->

    it "Add to unit",(done) ->
      expect(UnitModule.Units.findOne().amount).to.equal(0)
      event_doc =
        amount: 1032
        for_type: 'unit'
        for_id: unitIDs[0]
        organization_id: "k"

      organization_id = organizationIDs[0]

      EMethods.userEvent.call {organization_id, event_doc}, (err, res) ->
        expect(UnitModule.Units.findOne().amount).to.equal(1032)
        expect(EventModule.Events.findOne().for_id).to.equal(UnitModule.Units.findOne()._id)
        done()

    it "Take away from unit", (done) ->
      event_doc =
        amount: -103
        for_type: 'unit'
        for_id: unitIDs[0]
        organization_id: "k"

      organization_id = organizationIDs[0]

      EMethods.userEvent.call {organization_id, event_doc}, (err, res) ->
        expect(UnitModule.Units.findOne().amount).to.equal(1032-103)
        expect(EventModule.Events.findOne().for_id).to.equal(UnitModule.Units.findOne()._id)
        done()

    it "Take away more then current unit amount",(done) ->
      event_doc =
        amount: -1030
        for_type: 'unit'
        for_id: unitIDs[0]
        organization_id: "k"

      organization_id = organizationIDs[0]

      EMethods.userEvent.call {organization_id, event_doc}, (err, res) ->
        expect(err).to.have.property('error','amountError')
        expect(UnitModule.Units.findOne().amount).to.equal(1032-103)
        done()

    it "Add to yield", ->

    it "Take away from yield", ->

    it "Take away more then current yield amount", ->

    it "Add to inventory", ->

    it "Take away from inventory", ->

    it "Take away more then current inventory amount", ->




  describe "App Event Tests", ->





# ++++++++++++++++++++++++ Setup Methods

createUser = (done, email) ->
  doc =
    email: email
    password: '12345678'
    profile:
      first_name: faker.name.firstName()
      last_name: faker.name.lastName()

  Accounts.createUser doc, (err) ->
    throw err if err?
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
    throw err if err?
    organizationIDs.push res
    done()

createUnit = (done) ->
  unit_doc =
    name: faker.name.firstName()
    amount: 12
    organization_id: "NONkjhO"

  organization_id = organizationIDs[0]

  UMethods.insert.call {organization_id, unit_doc}, (err, res) ->
    throw err if err?
    unitIDs.push res
    done()

createYield = (done) ->
  ing = faker.company.companyName()
  ingredients.push ing
  yield_doc =
    amount: 2
    measurement_unit: "kg"
    ingredient_name: ing
    unit_id: unitIDs[0]
    organization_id: "nfo"

  organization_id = organizationIDs[0]

  YMethods.insert.call {organization_id, yield_doc}, (err, res) ->
    throw err if err?
    yieldIDs.push res
    done()

createInventory = (done, pIndex) ->
  inventory_doc =
    product_id: productIDs[pIndex]
    organization_id: "noo"

  organization_id = organizationIDs[0]

  IMethods.insert.call {organization_id, inventory_doc}, (err,res) ->
    throw err if err?
    inventoryIDS.push res
    done()

createProduct = (done, ings) ->
  ingredientsL = []
  for ing in ings
    ing_doc =
      ingredient_name: ing
      amount: (Random.fraction() * 100).toFixed(2)
      measurement_unit: "g"
    ingredientsL.push ing_doc

  product_doc =
    name: faker.commerce.productName()
    sku: faker.random.uuid()
    unit_price: 12.23
    currency: 'mxn'
    tax_rate: 16
    ingredients: ingredientsL
    organization_id: "nno"

  organization_id = organizationIDs[0]
  PMethods.insert.call {organization_id, product_doc}, (err, res) ->
    throw err if err?
    productIDs.push res
    done()

subscribe = (done, subto) ->
  callbacks =
    onStop: (err) ->
      throw err if err?
    onReady: () ->
      done()

  Meteor.subscribe(subto, organizationIDs[0], callbacks)


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
    throw err if err?
    done()
