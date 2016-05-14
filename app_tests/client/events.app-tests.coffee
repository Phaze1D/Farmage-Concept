faker = require 'faker'

{ chai, assert, expect } = require 'meteor/practicalmeteor:chai'
{ Meteor } = require 'meteor/meteor'
{ Accounts } = require 'meteor/accounts-base'
{ resetDatabase } = require 'meteor/xolvio:cleaner'
{ Random } = require 'meteor/random'
{ _ } = require 'meteor/underscore'


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
    it "Create User", (done)->
      createUser(done, faker.internet.email())

    it "Create Organization", (done)->
      createOrgan(done)

    it "Create Unit", (done)->
      createUnit(done)

    it "Create Yield", (done) ->
      createYield(done)

    it "Create Product", (done) ->
      ings = [ingredients[0]]
      createProduct(done, ings)

    it "Create Inventory", (done) ->
      createInventory(done, 0)



  describe "User Event Tests", ->
    it "Add to unit", ->

    it "Take away from unit", ->

    it "Add to yield", ->

    it "Take away from yield", ->

    it "Add to inventory", ->

    it "Take away from inventory", ->




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
