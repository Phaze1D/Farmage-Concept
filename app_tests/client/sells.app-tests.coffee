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

  describe "Preorder Create Tests", ->
    it "Duplicate sell details", (done) ->

      inventories = [
        {
        quantity_taken: 100
        inventory_id: inventoryIDs[0]
        },
        {
        quantity_taken: 100
        inventory_id: inventoryIDs[2]
        }
      ]

      details = [
        {
        product_id: productIDs[0]
        quantity: 2
        unit_price: 342.34
        tax_price: 324.2342
        inventories: inventories
        },
        {
        product_id: productIDs[0]
        quantity: 2
        unit_price: 32.32
        tax_price: 34.2342
        inventories: inventories
        }
      ]

      sell_doc =
        sub_total: 234.241
        tax_total: 234214.42
        discount: 10
        discount_type: false
        total_price: 34.23123
        details: details
        status: 'preorder'
        paid: true
        paid_date: new Date
        payment_method: 'cash'
        organization_id: organizationIDs[0]

      isOrder = false

      SMethods.preorder.call {sell_doc, isOrder}, (err, res) ->
        expect(err).to.have.property('error', 'duplicateError')
        done()

    it "Test all prices", (done) ->
      inventories = [
        {
        quantity_taken: 100
        inventory_id: inventoryIDs[0]
        },
        {
        quantity_taken: 100
        inventory_id: inventoryIDs[2]
        }
      ]

      details = [
        {
        product_id: productIDs[0]
        quantity: 2
        unit_price: 342.34
        tax_price: 324.2342
        inventories: inventories
        },
        {
        product_id: productIDs[1]
        quantity: 2
        unit_price: 342.34
        tax_price: 324.2342
        inventories: inventories
        }
      ]

      sell_doc =
        sub_total: 234.241
        tax_total: 234214.42
        discount: 10
        discount_type: false
        total_price: 34.23123
        details: details
        status: 'preorder'
        paid: true
        paid_date: new Date
        payment_method: 'cash'
        organization_id: organizationIDs[0]

      isOrder = false

      SMethods.preorder.call {sell_doc, isOrder}, (err, res) ->
        sell = SellModule.Sells.findOne()
        tax_price = 0
        for detail in sell.details
          product = ProductModule.Products.findOne(detail.product_id)
          expect(detail.inventories).to.not.exist
          expect(detail.unit_price).to.equal(product.unit_price)
          tax_price = (product.unit_price * detail.quantity) * (product.tax_rate/100)
          expect(detail.tax_price).to.equal Number(tax_price.toFixed(2))

        expect(sell.sub_total).to.equal(product.unit_price * 4)
        expect(sell.tax_total).to.equal Number((tax_price*2).toFixed(2))
        expect(sell.total_price).to.equal(sell.sub_total + sell.tax_total - 10)

        done()

  describe "Preorder to Order Tests", ->
    it "product missing", (done) ->
      inventories = [
        {
        quantity_taken: 100
        inventory_id: inventoryIDs[3]
        }
      ]

      organization_id = organizationIDs[0]
      sell_id = SellModule.Sells.findOne()._id

      SMethods.order.call {organization_id, sell_id, inventories}, (err, res) ->
        expect(err).to.have.property('error', 'productMismatch')
        done()

    it "inventory missing", (done) ->
        inventories = [
          {
          quantity_taken: 2
          inventory_id: inventoryIDs[1]
          }
        ]

        organization_id = organizationIDs[0]
        sell_id = SellModule.Sells.findOne()._id

        SMethods.order.call {organization_id, sell_id, inventories}, (err, res) ->
          expect(err).to.have.property('error', 'inventoryMissing')
          done()

    it "quantityMismatch error", (done) ->
        inventories = [
          {
          quantity_taken: 2
          inventory_id: inventoryIDs[1]
          },
          {
          quantity_taken: 1
          inventory_id: inventoryIDs[0]
          }
        ]

        organization_id = organizationIDs[0]
        sell_id = SellModule.Sells.findOne()._id


        SMethods.order.call {organization_id, sell_id, inventories}, (err, res) ->
          expect(err).to.have.property('error', 'quantityMismatch')
          done()

    it "happy", (done) ->
        inventories = [
          {
          quantity_taken: 1
          inventory_id: inventoryIDs[1]
          },
          {
          quantity_taken: 1
          inventory_id: inventoryIDs[0]
          },
          {
          quantity_taken: 2
          inventory_id: inventoryIDs[2]
          }
        ]

        organization_id = organizationIDs[0]
        sell_id = SellModule.Sells.findOne()._id

        SMethods.order.call {organization_id, sell_id, inventories}, (err, res) ->
          expect(err).to.not.exist
          done()

    it "double order check", (done) ->
      inventories = [
        {
        quantity_taken: 1
        inventory_id: inventoryIDs[1]
        },
        {
        quantity_taken: 1
        inventory_id: inventoryIDs[0]
        },
        {
        quantity_taken: 2
        inventory_id: inventoryIDs[2]
        }
      ]

      organization_id = organizationIDs[0]
      sell_id = SellModule.Sells.findOne()._id

      SMethods.order.call {organization_id, sell_id, inventories}, (err, res) ->
        expect(err).to.have.property('error', 'orderError')
        done()


  xdescribe "Order Create Test", ->

    it "stock overflow", (done) ->
      inventories = [
        {
        quantity_taken: 100
        inventory_id: inventoryIDs[0]
        },
        {
        quantity_taken: 100
        inventory_id: inventoryIDs[2]
        }
      ]

      details = [
        {
        product_id: productIDs[0]
        quantity: 2
        unit_price: 342.34
        tax_price: 324.2342
        inventories: inventories
        }
      ]

      sell_doc =
        sub_total: 234.241
        tax_total: 234214.42
        discount: 10
        discount_type: false
        total_price: 34.23123
        details: details
        status: 'preorder'
        paid: true
        paid_date: new Date
        payment_method: 'cash'
        organization_id: organizationIDs[0]

      isOrder = true

      SMethods.preorder.call {sell_doc, isOrder}, (err, res) ->
        expect(err).to.have.property('error', 'stockError')
        done()

    it "inventory duplicate", (done) ->

      inventories = [
        {
        quantity_taken: 1
        inventory_id: inventoryIDs[0]
        },
        {
        quantity_taken: 1
        inventory_id: inventoryIDs[0]
        }
      ]

      details = [
        {
        product_id: productIDs[0]
        quantity: 2
        unit_price: 342.34
        tax_price: 324.2342
        inventories: inventories
        }
      ]

      sell_doc =
        sub_total: 234.241
        tax_total: 234214.42
        discount: 10
        discount_type: false
        total_price: 34.23123
        details: details
        status: 'preorder'
        paid: true
        paid_date: new Date
        payment_method: 'cash'
        organization_id: organizationIDs[0]

      isOrder = true

      SMethods.preorder.call {sell_doc, isOrder}, (err, res) ->
        expect(err).to.have.property('error', 'duplicateError')
        done()

    it "quantity_taken and quantity mismatch", (done) ->
        inventories = [
          {
          quantity_taken: 1
          inventory_id: inventoryIDs[0]
          }
        ]

        details = [
          {
          product_id: productIDs[0]
          quantity: 2
          unit_price: 342.34
          tax_price: 324.2342
          inventories: inventories
          }
        ]

        sell_doc =
          sub_total: 234.241
          tax_total: 234214.42
          discount: 10
          discount_type: false
          total_price: 34.23123
          details: details
          status: 'preorder'
          paid: true
          paid_date: new Date
          payment_method: 'cash'
          organization_id: organizationIDs[0]

        isOrder = true

        SMethods.preorder.call {sell_doc, isOrder}, (err, res) ->
          expect(err).to.have.property('error', 'quantityMismatch')
          done()

    it "happy", (done) ->
      preA = InventoryModule.Inventories.findOne(inventoryIDs[0]).amount
      inventories = [
        {
        quantity_taken: 2
        inventory_id: inventoryIDs[0]
        }
      ]

      details = [
        {
        product_id: productIDs[0]
        quantity: 2
        unit_price: 342.34
        tax_price: 324.2342
        inventories: inventories
        }
      ]

      sell_doc =
        sub_total: 234.241
        tax_total: 234214.42
        discount: 10
        discount_type: false
        total_price: 34.23123
        details: details
        status: 'preorder'
        paid: true
        paid_date: new Date
        payment_method: 'cash'
        organization_id: organizationIDs[0]

      isOrder = true

      SMethods.preorder.call {sell_doc, isOrder}, (err, res) ->
        expect(err).to.not.exist
        expect(InventoryModule.Inventories.findOne(inventoryIDs[0]).amount).to.equal(preA - 2)
        expect(EventModule.Events.findOne $and: [ for_id: inventoryIDs[0], amount: -2]).to.exist
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
