faker = require 'faker'

{ chai, assert, expect } = require 'meteor/practicalmeteor:chai'
{ Meteor } = require 'meteor/meteor'
{ Accounts } = require 'meteor/accounts-base'
{ resetDatabase } = require 'meteor/xolvio:cleaner'
{ Random } = require 'meteor/random'
{ _ } = require 'meteor/underscore'


EventModule = require '../../imports/api/collections/events/events.coffee'
InventoryModule = require '../../imports/api/collections/inventories/inventories.coffee'
ProductModule = require '../../imports/api/collections/products/products.coffee'
SellModule = require '../../imports/api/collections/sells/sells.coffee'

EMethods = require '../../imports/api/collections/events/methods.coffee'
OMethods = require '../../imports/api/collections/organizations/methods.coffee'
PMethods = require '../../imports/api/collections/products/methods.coffee'
IMethods = require '../../imports/api/collections/inventories/methods.coffee'
InMethods = require '../../imports/api/collections/ingredients/methods.coffee'
SMethods = require '../../imports/api/collections/sells/methods.coffee'


sellIDs = []
organizationIDs = []
productIDs = []
inventoryIDs = []
ingredientIDs = []


describe "Sells Client Side Test", ->
  before ->
    resetDatabase(null);

  describe "Setup", ->
    after( (done) ->
      @timeout(5000)
      setTimeout(done, 3000)
      return
    )

    it "Create User", (done) ->
      createUser(done, faker.internet.email())

    it "Create Organization", (done) ->
      createOrgan(done)

    it "Create Ingredient",(done) ->
      createIngredient(done, 0)

    it "Create Product", (done) ->
      ings = [ingredientIDs[0]]
      createProduct(done, ings)

    it "Create Product", (done) ->
      ings = [ingredientIDs[0]]
      createProduct(done, ings)

    it "Create Product", (done) ->
      ings = [ingredientIDs[0]]
      createProduct(done, ings)

    it "Create Product", (done) ->
      ings = [ingredientIDs[0]]
      createProduct(done, ings)

    it "Create Inventory", (done) ->
      createInventory(done, 0)

    it "Add to Inventory", (done) ->
      addToInventory(done, 0, 30)

    it "Create Inventory", (done) ->
      createInventory(done, 0)

    it "Add to Inventory", (done) ->
      addToInventory(done, 1, 30)

    it "Create Inventory", (done) ->
      createInventory(done, 1)

    it "Add to Inventory", (done) ->
      addToInventory(done, 2, 30)

    it "Create Inventory", (done) ->
      createInventory(done, 2)

    it "Add to Inventory", (done) ->
      addToInventory(done, 3, 30)

    it "Create Inventory", (done) ->
      createInventory(done, 2)

    it "Add to Inventory", (done) ->
      addToInventory(done, 4, 30)

    it "Subscribe to inventory", (done) ->
      subscribe(done, 'inventories')

    it "Subscribe to events", (done) ->
      subscribe(done, 'events')

    it "Subscribe to products", (done) ->
      subscribe(done, 'products')

    it "Subscribe to sells", (done) ->
      subscribe(done, 'sells')


  describe "Insert", ->
    it "Validate duplicate products", (done) ->
      details = [
        {
          product_id: productIDs[0]
          quantity: 12
        },
        {
          product_id: productIDs[0]
          quantity: 1
        }
      ]

      sell_doc =
        details: details
        status: 'preorder'
        total_price: 0
        organization_id: organizationIDs[0]

      SMethods.insert.call {sell_doc}, (err, res) ->
        expect(err).to.have.property('error', 'duplicateError')
        done()

    it "Remove Zero Details ", (done) ->
      details = [
        {
          product_id: productIDs[0]
          quantity: 12
        },
        {
          product_id: productIDs[1]
          quantity: 0
        }
      ]

      sell_doc =
        details: details
        status: 'preorder'
        total_price: 0
        organization_id: organizationIDs[0]

      SMethods.insert.call {sell_doc}, (err, res) ->
        expect(SellModule.Sells.findOne(res).details.length).to.equal(1)
        sellIDs.push res
        done()

    it "Remove un auth fields", (done) ->
      details = [
        {
          product_id: productIDs[0]
          quantity: 12
          inventories: [
            inventory_id: inventoryIDs[0]
            quantity_taken: 12
          ]
        }
      ]

      sell_doc =
        details: details
        status: 'preorder'
        paid: true
        discount: 12
        payment_method: 'cash'
        organization_id: organizationIDs[0]

      SMethods.insert.call {sell_doc}, (err, res) ->
        sell = SellModule.Sells.findOne(res)
        console.log sell
        expect(sell.paid).to.equal(false)
        expect(sell.details[0].inventories.length).to.equal(0)
        sellIDs.push res
        done()

  describe "Add Items", ->
    it "Quantity over load", (done) ->
      inventories = [
        {
          inventory_id: inventoryIDs[0]
          quantity_taken: 100
        }
      ]

      organization_id = organizationIDs[0]
      sell_id = sellIDs[1]

      SMethods.addItems.call {organization_id, sell_id, inventories}, (err, res) ->
        expect(err).to.have.property('error', 'quantityError')
        done()

    it "Check new details", (done) ->
      expect(SellModule.Sells.findOne(sellIDs[1]).details[0].quantity).to.equal(12)
      inventories = [
        {
          inventory_id: inventoryIDs[0]
          quantity_taken: 1
        },
        {
          inventory_id: inventoryIDs[2]
          quantity_taken: 1
        }
      ]

      organization_id = organizationIDs[0]
      sell_id = sellIDs[1]

      SMethods.addItems.call {organization_id, sell_id, inventories}, (err, res) ->
        sell = SellModule.Sells.findOne(sellIDs[1])
        console.log sell
        expect(de.quantity).to.equal(1) for de in sell.details
        done()


  describe "Put Back", ->

  describe "Update Un paid", ->

  describe "Delete un paid", ->

  describe "Pay", ->

  describe "Update paid", ->







# ++++++++++++++++++++++++ Setup Methods
addToInventory = (done, index, amount) ->
  event_doc =
    amount: amount
    for_type: 'inventory'
    for_id: inventoryIDs[index]
    organization_id: organizationIDs[0]

  EMethods.userEvent.call {event_doc}, (err, res) ->
    throw err if err?
    done()

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

createInventory = (done, pIndex) ->
  inventory_doc =
    product_id: productIDs[pIndex]
    organization_id: organizationIDs[0]


  IMethods.insert.call {inventory_doc}, (err,res) ->
    throw err if err?
    inventoryIDs.push res
    done()

createIngredient = (done, i) ->
  ingredient_doc =
    name: faker.name.firstName()
    measurement_unit: 'kg'
    organization_id: organizationIDs[i]

  InMethods.insert.call {ingredient_doc}, (err, res) ->
    throw err if err?
    ingredientIDs.push res
    done()

createProduct = (done, ings) ->
  ingredientsL = []
  for ing in ings
    ing_doc =
      ingredient_id: ing
      amount: (Random.fraction() * 100)
    ingredientsL.push ing_doc

  product_doc =
    name: faker.commerce.productName()
    sku: faker.random.uuid()
    unit_price: 12.23
    currency: 'mxn'
    tax_rate: 16
    ingredients: ingredientsL
    organization_id: organizationIDs[0]

  PMethods.insert.call {product_doc}, (err, res) ->
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
