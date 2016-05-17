faker = require 'faker'
Big = require 'big.js'

{ chai, assert, expect } = require 'meteor/practicalmeteor:chai'
{ Meteor } = require 'meteor/meteor'
{ Accounts } = require 'meteor/accounts-base'
{ resetDatabase } = require 'meteor/xolvio:cleaner'
{ Random } = require 'meteor/random'
{ _ } = require 'meteor/underscore'

UnitModule = require '../../imports/api/collections/units/units.coffee'
YieldModule = require '../../imports/api/collections/yields/yields.coffee'
EventModule = require '../../imports/api/collections/events/events.coffee'
InventoryModule = require '../../imports/api/collections/inventories/inventories.coffee'
ProductModule = require '../../imports/api/collections/products/products.coffee'

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

    it "Subscribe to yields", (done) ->
      subscribe(done, 'yields')

    it "Subscribe to inventory", (done) ->
      subscribe(done, 'inventories')

    it "Subscribe to events", (done) ->
      subscribe(done, 'events')

    it "Subscribe to products", (done) ->
      subscribe(done, 'products')




  describe "User Event Tests", ->

    it "Add to unit",(done) ->
      expect(UnitModule.Units.findOne().amount).to.equal(0)
      event_doc =
        amount: 1032
        for_type: 'unit'
        for_id: unitIDs[0]
        organization_id: organizationIDs[0]

      EMethods.userEvent.call {event_doc}, (err, res) ->
        expect(UnitModule.Units.findOne().amount).to.equal(1032)
        expect(EventModule.Events.findOne().for_id).to.equal(UnitModule.Units.findOne()._id)
        done()

    it "Take away from unit", (done) ->
      event_doc =
        amount: -103
        for_type: 'unit'
        for_id: unitIDs[0]
        organization_id: organizationIDs[0]

      EMethods.userEvent.call {event_doc}, (err, res) ->
        expect(UnitModule.Units.findOne().amount).to.equal(1032-103)
        expect(EventModule.Events.findOne().for_id).to.equal(UnitModule.Units.findOne()._id)
        done()

    it "Take away more then current unit amount",(done) ->
      event_doc =
        amount: -1030
        for_type: 'unit'
        for_id: unitIDs[0]
        organization_id: organizationIDs[0]

      EMethods.userEvent.call {event_doc}, (err, res) ->
        expect(err).to.have.property('error','amountError')
        expect(UnitModule.Units.findOne().amount).to.equal(1032-103)
        done()

    it "Add to yield",(done) ->
      expect(YieldModule.Yields.findOne().amount).to.equal(0)
      event_doc =
        amount: 10329
        for_type: 'yield'
        for_id: yieldIDs[0]
        organization_id: organizationIDs[0]

      EMethods.userEvent.call {event_doc}, (err, res) ->
        expect(YieldModule.Yields.findOne().amount).to.equal(10329)
        expect(EventModule.Events.findOne(_id: res).for_id).to.equal(YieldModule.Yields.findOne()._id)
        done()

    it "Take away from yield", (done) ->
      event_doc =
        amount: -103
        for_type: 'yield'
        for_id: yieldIDs[0]
        organization_id: organizationIDs[0]

      EMethods.userEvent.call {event_doc}, (err, res) ->
        expect(YieldModule.Yields.findOne().amount).to.equal(10329 - 103)
        expect(EventModule.Events.findOne(_id: res).for_id).to.equal(YieldModule.Yields.findOne()._id)
        done()

    it "Take away more then current yield amount", (done) ->
      event_doc =
        amount: -103343
        for_type: 'yield'
        for_id: yieldIDs[0]
        organization_id: organizationIDs[0]

      EMethods.userEvent.call {event_doc}, (err, res) ->
        expect(err).to.have.property('error','amountError')
        done()

    it "Add to inventory", (done) ->
      event_doc =
        amount: 1232
        for_type: 'inventory'
        for_id: inventoryIDS[0]
        organization_id: organizationIDs[0]

      EMethods.userEvent.call {event_doc}, (err, res) ->
        expect(InventoryModule.Inventories.findOne().amount).to.equal(1232)
        expect(EventModule.Events.findOne(_id: res).for_id).to.equal(InventoryModule.Inventories.findOne()._id)
        expect(err).to.not.exist
        done()

    it "Fake amount update", (done) ->
      organization_id = organizationIDs[0]
      inventory_id = inventoryIDS[0]

      inventory_doc =
        amount: 4999

      IMethods.update.call {organization_id, inventory_id, inventory_doc}, (err, res) ->
        expect(InventoryModule.Inventories.findOne().amount).to.equal(1232)
        done()


    it "Take away from inventory", (done) ->
      event_doc =
        amount: -1232
        for_type: 'inventory'
        for_id: inventoryIDS[0]
        organization_id: organizationIDs[0]

      EMethods.userEvent.call {event_doc}, (err, res) ->
        expect(InventoryModule.Inventories.findOne().amount).to.equal(0)
        expect(EventModule.Events.findOne(_id: res).for_id).to.equal(InventoryModule.Inventories.findOne()._id)
        expect(err).to.not.exist
        done()

    it "Take away more then current inventory amount", (done) ->
      event_doc =
        amount: -232343
        for_type: 'inventory'
        for_id: inventoryIDS[0]
        organization_id: organizationIDs[0]

      EMethods.userEvent.call {event_doc}, (err, res) ->
        expect(InventoryModule.Inventories.findOne().amount).to.equal(0)
        expect(err).to.have.property('error', 'amountError')
        done()


  describe "App Event Tests", ->
    it "Single ingredient ", (done) ->
      organization_id = organizationIDs[0]
      inventory_id = inventoryIDS[0]

      amount = 40
      cr = 0.324
      at = Number new Big(ProductModule.Products.findOne().ingredients[0].amount).times(amount * cr)
      yao = Number new Big(YieldModule.Yields.findOne().amount).minus(at)
      iao = InventoryModule.Inventories.findOne().amount + amount

      yield_objects = [
        yield_id: YieldModule.Yields.findOne()._id
        amount_taken: at
        conversation_rate: cr
      ]

      EMethods.packageEvent.call {organization_id, inventory_id, yield_objects, amount}, (err,res) ->
        console.log err
        console.log ProductModule.Products.findOne().ingredients[0].amount if err?
        console.log "#{yao} -- #{YieldModule.Yields.findOne().amount}"

        expect(err).to.not.exist
        expect(YieldModule.Yields.findOne().amount).to.equal(Number yao.toFixed(10))
        expect(InventoryModule.Inventories.findOne().amount).to.equal(iao)
        expect(InventoryModule.Inventories.findOne().yield_objects.length).to.equal(1)
        done()

    it "Single ingredient multiple yield objects", (done) ->
      organization_id = organizationIDs[0]
      inventory_id = inventoryIDS[0]

      yyaB = new Big(YieldModule.Yields.findOne().amount)
      pIA = new Big(ProductModule.Products.findOne().ingredients[0].amount)

      yao = Number(yyaB.minus pIA.times(40))
      iao = InventoryModule.Inventories.findOne().amount + 40

      yield_objects = [
        {
          yield_id: YieldModule.Yields.findOne()._id
          amount_taken: Number(pIA.times(20))
          conversation_rate: 1
        },
        {
          yield_id: YieldModule.Yields.findOne()._id
          amount_taken: Number(pIA.times(20))
          conversation_rate: 1
        }

      ]

      amount = 40

      EMethods.packageEvent.call {organization_id, inventory_id, yield_objects, amount}, (err,res) ->
        console.log "#{yao} -- #{YieldModule.Yields.findOne().amount}"
        expect(err).to.not.exist
        expect(YieldModule.Yields.findOne().amount).to.equal(yao)
        expect(InventoryModule.Inventories.findOne().amount).to.equal(iao)
        done()


    it "Yield amount taken failed", ->

    it "Same conversation_rate", ->

    it "Different conversation_rate", ->

    it "Single ingredient amount failed", ->

    it "ingredient name mismatch", ->

    it "Multiple ingredients", ->








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
    organization_id: organizationIDs[0]

  organization_id = () ->
    console.log "hakcing"

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
    organization_id: organizationIDs[0]


  YMethods.insert.call {yield_doc}, (err, res) ->
    throw err if err?
    yieldIDs.push res
    done()

createInventory = (done, pIndex) ->
  inventory_doc =
    product_id: productIDs[pIndex]
    organization_id: organizationIDs[0]


  IMethods.insert.call {inventory_doc}, (err,res) ->
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
