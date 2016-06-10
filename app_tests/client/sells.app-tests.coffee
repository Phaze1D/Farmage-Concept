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


xdescribe "Sells Client Side Test", ->
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
      old = InventoryModule.Inventories.findOne(inventoryIDs[0]).amount
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
        expect(de.quantity).to.equal(1) for de in sell.details
        expect(old).to.equal(InventoryModule.Inventories.findOne(inventoryIDs[0]).amount + 1)
        expect(EventModule.Events.findOne({for_id: inventoryIDs[0]}, sort: {createdAt: -1}).amount).to.equal(-1)
        done()

    it "Negative quantities", (done) ->
      inventories = [
        {
          inventory_id: inventoryIDs[0]
          quantity_taken: 1
        },
        {
          inventory_id: inventoryIDs[2]
          quantity_taken: -1
        }
      ]

      organization_id = organizationIDs[0]
      sell_id = sellIDs[1]

      SMethods.addItems.call {organization_id, sell_id, inventories}, (err, res) ->
        expect(err).to.have.property('error', 'validation-error')
        done()

  describe "Put Back", ->
    it "Check 0 details", (done) ->
      old = InventoryModule.Inventories.findOne(inventoryIDs[2]).amount
      expect(SellModule.Sells.findOne(sellIDs[1]).details.length).to.equal(2)
      inventories = [
        {
          inventory_id: inventoryIDs[2]
          quantity_taken: 1
        }
      ]

      organization_id = organizationIDs[0]
      sell_id = sellIDs[1]

      SMethods.putBackItems.call {organization_id, sell_id, inventories}, (err, res) ->
        sell = SellModule.Sells.findOne(sellIDs[1])
        expect(sell.details.length).to.equal(1)
        expect(old).to.equal( InventoryModule.Inventories.findOne(inventoryIDs[2]).amount - 1)
        done()

    it "Over taking", (done) ->
      inventories = [
        {
          inventory_id: inventoryIDs[0]
          quantity_taken: 4
        }
      ]

      organization_id = organizationIDs[0]
      sell_id = sellIDs[1]

      SMethods.putBackItems.call {organization_id, sell_id, inventories}, (err, res) ->
        expect(err).to.have.property('error', 'putBackError')
        done()

    it "Remove non existing product in sell", (done) ->
      inventories = [
        {
          inventory_id: inventoryIDs[4]
          quantity_taken: 4
        }
      ]

      organization_id = organizationIDs[0]
      sell_id = sellIDs[1]

      SMethods.putBackItems.call {organization_id, sell_id, inventories}, (err, res) ->
        expect(err).to.have.property('error', 'putBackError')
        done()

    it "Remove non existing inventory in sell", (done) ->
      inventories = [
        {
          inventory_id: inventoryIDs[1]
          quantity_taken: 4
        }
      ]

      organization_id = organizationIDs[0]
      sell_id = sellIDs[1]

      SMethods.putBackItems.call {organization_id, sell_id, inventories}, (err, res) ->
        expect(err).to.have.property('error', 'putBackError')
        done()

  describe "Update Un paid", ->
    it "Update details with new product", (done) ->
      console.log SellModule.Sells.findOne(sellIDs[1])
      expect(SellModule.Sells.findOne(sellIDs[1]).details.length).to.equal(1)

      details = [
        product_id: productIDs[2]
        unit_price: 131
        quantity: 23
      ]

      sell_doc =
        details: details

      organization_id = organizationIDs[0]
      sell_id = sellIDs[1]

      SMethods.update.call {organization_id, sell_id, sell_doc}, (err, res) ->
        expect(err).to.not.exist
        console.log SellModule.Sells.findOne(sellIDs[1])
        expect(SellModule.Sells.findOne(sellIDs[1]).details.length).to.equal(2)
        done()

    it "Update removing detail without inventories", (done) ->
      expect(SellModule.Sells.findOne(sellIDs[1]).details.length).to.equal(2)
      details = [
        product_id: productIDs[2]
        unit_price: 131
        quantity: 0
      ]

      sell_doc =
        details: details

      organization_id = organizationIDs[0]
      sell_id = sellIDs[1]

      SMethods.update.call {organization_id, sell_id, sell_doc}, (err, res) ->
        expect(err).to.not.exist
        expect(SellModule.Sells.findOne(sellIDs[1]).details.length).to.equal(1)
        done()

    it "Update detail with inventories to 0", (done) ->
      details = [
        product_id: productIDs[0]
        unit_price: 131
        quantity: 0
      ]

      sell_doc =
        details: details

      organization_id = organizationIDs[0]
      sell_id = sellIDs[1]

      SMethods.update.call {organization_id, sell_id, sell_doc}, (err, res) ->
        expect(err).to.not.exist
        sell = SellModule.Sells.findOne(sellIDs[1])
        expect(sell.details.length).to.equal(1)
        expect(sell.details[0].quantity).to.equal(0)
        done()

  describe "Delete un paid", ->
    it "Delete with inventories", (done) ->
      organization_id = organizationIDs[0]
      sell_id = sellIDs[1]

      SMethods.deleteSell.call {organization_id, sell_id}, (err, res) ->
        expect(err).to.have.property('error', 'deleteError')
        done()

    it "Remove inventory", (done) ->
      inventories = [
        {
          inventory_id: inventoryIDs[0]
          quantity_taken: 1
        }
      ]

      organization_id = organizationIDs[0]
      sell_id = sellIDs[1]

      SMethods.putBackItems.call {organization_id, sell_id, inventories}, (err, res) ->
        expect(err).to.not.exist
        done()

    it "update detail", (done) ->
        details = [
          product_id: productIDs[2]
          unit_price: 131
          quantity: 23
        ]

        sell_doc =
          details: details

        organization_id = organizationIDs[0]
        sell_id = sellIDs[1]

        SMethods.update.call {organization_id, sell_id, sell_doc}, (err, res) ->
          expect(err).to.not.exist
          expect(SellModule.Sells.findOne(sellIDs[1]).details.length).to.equal(1)
          done()

    it "Delete without inventories", (done) ->
      expect(SellModule.Sells.find().count()).to.equal(2)
      organization_id = organizationIDs[0]
      sell_id = sellIDs[1]

      SMethods.deleteSell.call {organization_id, sell_id}, (err, res) ->
        expect(SellModule.Sells.find().count()).to.equal(1)
        expect(err).to.not.exist
        done()

  describe "Pay", ->
    it "No physical Items", (done) ->
      organization_id = organizationIDs[0]
      sell_id = sellIDs[0]

      SMethods.pay.call {organization_id, sell_id}, (err, res) ->
        expect(err).to.have.property('reason', 'Cannot paid sell that has no physical items')
        done()

    it "Add physical items", (done) ->
      inventories = [
        {
          inventory_id: inventoryIDs[0]
          quantity_taken: 1
        },
        {
          inventory_id: inventoryIDs[1]
          quantity_taken: 1
        }
      ]

      organization_id = organizationIDs[0]
      sell_id = sellIDs[0]

      SMethods.addItems.call {organization_id, sell_id, inventories}, (err, res) ->
        expect(err).to.not.exist
        done()

    it "Update sell", (done) ->
      details = [
        product_id: productIDs[0]
        unit_price: 131
        quantity: 0
      ]

      sell_doc =
        details: details

      organization_id = organizationIDs[0]
      sell_id = sellIDs[0]

      SMethods.update.call {organization_id, sell_id, sell_doc}, (err, res) ->
        expect(err).to.not.exist
        done()

    it "No physical Items", (done) ->
      expect(SellModule.Sells.findOne().details.length).to.equal(1)
      organization_id = organizationIDs[0]
      sell_id = sellIDs[0]

      SMethods.pay.call {organization_id, sell_id}, (err, res) ->
        expect(err).to.have.property('error', 'detailMismatch')
        done()

    it "Add physical items", (done) ->
      inventories = [
        {
          inventory_id: inventoryIDs[0]
          quantity_taken: 1
        },
        {
          inventory_id: inventoryIDs[1]
          quantity_taken: 1
        }
      ]

      organization_id = organizationIDs[0]
      sell_id = sellIDs[0]

      SMethods.addItems.call {organization_id, sell_id, inventories}, (err, res) ->
        expect(err).to.not.exist
        done()

    it "pay", (done) ->
      organization_id = organizationIDs[0]
      sell_id = sellIDs[0]

      SMethods.pay.call {organization_id, sell_id}, (err, res) ->
        expect(err).to.not.exist
        expect( SellModule.Sells.findOne().paid ).to.equal(true)
        done()

    it "pay double", (done) ->
      organization_id = organizationIDs[0]
      sell_id = sellIDs[0]

      SMethods.pay.call {organization_id, sell_id}, (err, res) ->
        expect(err).to.have.property('reason', 'sell has already been paid')
        done()

  describe "Update paid", ->
    it "Add physical items", (done) ->
      inventories = [
        {
          inventory_id: inventoryIDs[0]
          quantity_taken: 1
        },
        {
          inventory_id: inventoryIDs[1]
          quantity_taken: 1
        }
      ]

      organization_id = organizationIDs[0]
      sell_id = sellIDs[0]

      SMethods.addItems.call {organization_id, sell_id, inventories}, (err, res) ->
        expect(err).to.exist
        expect(err).to.have.property('error', 'itemError')
        done()

    it "Remove physical items", (done) ->
      inventories = [
        {
          inventory_id: inventoryIDs[0]
          quantity_taken: 1
        },
        {
          inventory_id: inventoryIDs[1]
          quantity_taken: 1
        }
      ]

      organization_id = organizationIDs[0]
      sell_id = sellIDs[0]

      SMethods.putBackItems.call {organization_id, sell_id, inventories}, (err, res) ->
        expect(err).to.exist
        expect(err).to.have.property('error', 'itemError')
        done()

    it "Update detail with inventories to 0", (done) ->
      details = [
        product_id: productIDs[0]
        unit_price: 131
        quantity: 0
      ]

      sell_doc =
        details: details
        status: 'nono'

      organization_id = organizationIDs[0]
      sell_id = sellIDs[0]

      SMethods.update.call {organization_id, sell_id, sell_doc}, (err, res) ->
        expect(err).to.not.exist
        sell = SellModule.Sells.findOne(sellIDs[0])
        expect(sell.details.length).to.equal(1)
        expect(sell.details[0].quantity).to.equal(4)
        expect(sell.status).to.equal('nono')
        done()

  describe "Delete paid", ->
    it "Delete paid", (done) ->
      expect(SellModule.Sells.find().count()).to.equal(1)
      organization_id = organizationIDs[0]
      sell_id = sellIDs[0]

      SMethods.deleteSell.call {organization_id, sell_id}, (err, res) ->
        expect(SellModule.Sells.find().count()).to.equal(1)
        expect(err).to.exist
        expect(err).to.have.property('error', 'deleteError')
        done()


  describe "Extra", (done) ->
    it "insert", (done) ->
      details = [
        {
          product_id: productIDs[0]
          quantity: 32
        },
        {
          product_id: productIDs[1]
          quantity: 12
        },
        {
          product_id: productIDs[2]
          quantity: 13
        },
        {
          product_id: productIDs[3]
          quantity: 13
        },

      ]

      sell_doc =
        details: details
        status: 'preorder'
        total_price: 0
        organization_id: organizationIDs[0]

      SMethods.insert.call {sell_doc}, (err, res) ->
        expect(err).to.not.exist
        sellIDs.push res
        done()

    it "Add inventories", (done) ->
      inventories = [
        {
          inventory_id: inventoryIDs[0]
          quantity_taken: 20
        },
        {
          inventory_id: inventoryIDs[1]
          quantity_taken: 20
        },
        {
          inventory_id: inventoryIDs[2]
          quantity_taken: 12
        },
        {
          inventory_id: inventoryIDs[3]
          quantity_taken: 5
        },
        {
          inventory_id: inventoryIDs[4]
          quantity_taken: 23
        }
      ]

      organization_id = organizationIDs[0]
      sell_id = sellIDs[2]

      SMethods.addItems.call {organization_id, sell_id, inventories}, (err, res) ->
        expect(err).to.not.exist
        done()

    it "pay", (done) ->
      organization_id = organizationIDs[0]
      sell_id = sellIDs[2]

      SMethods.pay.call {organization_id, sell_id}, (err, res) ->
        expect(err).to.exist
        done()

    it "Update", (done)->

      details = [
        product_id: productIDs[3]
        unit_price: 131
        quantity: 0
      ]

      sell_doc =
        details: details

      organization_id = organizationIDs[0]
      sell_id = sellIDs[2]

      SMethods.update.call {organization_id, sell_id, sell_doc}, (err, res) ->
        expect(err).to.not.exist
        sell = SellModule.Sells.findOne(sellIDs[2])
        console.log sell
        expect(sell.details.length).to.equal(3)
        done()


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
  organization_doc =
    name: faker.company.companyName()
    email: faker.internet.email()

  OMethods.insert.call {organization_doc}, (err, res) ->
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
