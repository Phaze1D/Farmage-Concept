faker = require 'faker'

{ chai, assert, expect } = require 'meteor/practicalmeteor:chai'
{ Meteor } = require 'meteor/meteor'
{ Accounts } = require 'meteor/accounts-base'
{ resetDatabase } = require 'meteor/xolvio:cleaner'
{ Random } = require 'meteor/random'
{ _ } = require 'meteor/underscore'

UnitModule = require '../../imports/api/collections/units/units.coffee'
ExpenseModule = require '../../imports/api/collections/expenses/expenses.coffee'
OrganizationModule = require '../../imports/api/collections/organizations/organizations.coffee'

UMethods = require '../../imports/api/collections/units/methods.coffee'
PMethods = require '../../imports/api/collections/providers/methods.coffee'
RMethods = require '../../imports/api/collections/receipts/methods.coffee'
OMethods = require '../../imports/api/collections/organizations/methods.coffee'

{ inviteUser } = require '../../imports/api/collections/users/methods.coffee'

{
  insert
  update
} = require '../../imports/api/collections/expenses/methods.coffee'


xdescribe "Expenses Full App Client", ->
  before( (done) ->
    Meteor.logout( (err) ->
      done()
    )
  )

  organizationIDs = []
  unitIDs = []
  providerIDs = []
  receiptIDs = []
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

  createOrgan = (done) ->
    organ_doc =
      name: faker.company.companyName()
      email: faker.internet.email()

    OMethods.insert.call organ_doc, (err, res) ->
      organizationIDs.push res
      expect(err).to.not.exist
      done()


  describe "Expenses insert", ->
    it "Without unit id",(done) ->
      expense_doc =
        price: 12.21
        currency: "MXN"
        name: "Bottle"
        quantity: 1

      organization_id = "NONO"

      insert.call {organization_id, expense_doc}, (err, res) ->
        expect(err).to.have.property('error', 'validation-error')
        expect(err).to.have.property('reason', 'Unit id is required')
        done()


    it "Currency max limit ",(done) ->
      expense_doc =
        price: 12.21
        currency: "MXNEEE"
        name: "Bottle"
        quantity: 1
        unit_id: "NOON"

      organization_id = "NONO"

      insert.call {organization_id, expense_doc}, (err, res) ->
        expect(err).to.have.property('error', 'validation-error')
        expect(err).to.have.property('reason', 'currency_ISO_4217 cannot exceed 3 characters')
        done()


    it "Create user", (done) ->
      createUser(done, faker.internet.email())

    it "Create organization",(done) ->
      createOrgan(done)

    it 'Subscribe to ', (done) ->
      callbacks =
        onStop: (err) ->

        onReady: () ->
          done()

      subHandler = Meteor.subscribe('expenses', organizationIDs[0], callbacks)


    it "create unit", (done) ->
      unit_doc =
        name: faker.company.companyName()
        amount: 12
        organization_id: organizationIDs[0]

      UMethods.insert.call {unit_doc}, (err, res) ->
        unitIDs.push res
        done()

    it "Insert valid", (done) ->
      expense_doc =
        price: 12.21
        currency: "MXN"
        name: "Bottle"
        quantity: 1
        unit_id: unitIDs[0]
        organization_id: organizationIDs[0]

      insert.call {expense_doc}, (err, res) ->
        expect(err).to.not.exist
        done()



  describe "Expenses insert with provider", ->
    it "Insert with invalid provider id",(done) ->
      expense_doc =
        price: 12.21
        currency: "MXN"
        name: "Bottle"
        quantity: 1
        provider_id: "NON"
        unit_id: unitIDs[0]
        organization_id: organizationIDs[0]

      insert.call {expense_doc}, (err, res) ->
        expect(err).to.have.property('reason', 'provider does not belong')
        done()


    it "Create organization",(done) ->
      createOrgan(done)

    it "Create provider", (done) ->

      provider_doc =
        first_name: faker.name.firstName()
        last_name: faker.name.lastName()
        organization_id: organizationIDs[1]

      PMethods.insert.call {provider_doc}, (err, res) ->
        expect(err).to.not.exist
        providerIDs.push res
        done()

    it "Insert provider that does not exist in organ",(done) ->
      expense_doc =
        price: 12.21
        currency: "MXN"
        name: "Bottle"
        quantity: 1
        provider_id: providerIDs[0]
        unit_id: unitIDs[0]
        organization_id: organizationIDs[0]

      organization_id = organizationIDs[0]

      insert.call {organization_id, expense_doc}, (err, res) ->
        expect(err).to.have.property('reason', 'provider does not belong')
        done()

    it "Create provider", (done) ->
      organization_id = organizationIDs[0]
      provider_doc =
        first_name: faker.name.firstName()
        last_name: faker.name.lastName()
        organization_id: organization_id

      PMethods.insert.call {organization_id, provider_doc}, (err, res) ->
        expect(err).to.not.exist
        providerIDs.push res
        done()

    it "Insert provider that does exist in organ",(done) ->
      expense_doc =
        price: 12.21
        currency: "MXN"
        name: "Bottle"
        quantity: 1
        provider_id: providerIDs[1]
        unit_id: unitIDs[0]
        organization_id: organizationIDs[0]

      organization_id = organizationIDs[0]

      insert.call {organization_id, expense_doc}, (err, res) ->
        expect(err).to.not.exist
        done()



  describe "Expenses insert with receipts", ->
    it "Insert with invalid receipt id",(done) ->
      expense_doc =
        price: 12.21
        currency: "MXN"
        name: "Bottle"
        quantity: 1
        receipt_id: "NON"
        unit_id: unitIDs[0]
        organization_id: organizationIDs[0]

      organization_id = organizationIDs[0]

      insert.call {organization_id, expense_doc}, (err, res) ->
        expect(err).to.have.property('reason', 'receipt does not belong')
        done()

    it "Create receipt", (done) ->
      organization_id = organizationIDs[1]
      receipt_doc =
        receipt_image_url: faker.internet.avatar()
        organization_id: organization_id

      RMethods.insert.call {organization_id, receipt_doc}, (err, res) ->
        expect(err).to.not.exist
        receiptIDs.push res
        done()

    it "Insert receipt that does not exist in organ",(done) ->
      expense_doc =
        price: 12.21
        currency: "MXN"
        name: "Bottle"
        quantity: 1
        receipt_id: receiptIDs[0]
        unit_id: unitIDs[0]
        organization_id: organizationIDs[0]

      organization_id = organizationIDs[0]

      insert.call {organization_id, expense_doc}, (err, res) ->
        expect(err).to.have.property('reason', 'receipt does not belong')
        done()

    it "Create receipt", (done) ->
      organization_id = organizationIDs[0]
      receipt_doc =
        receipt_image_url: faker.internet.avatar()
        organization_id: organization_id

      RMethods.insert.call {organization_id, receipt_doc}, (err, res) ->
        expect(err).to.not.exist
        receiptIDs.push res
        done()

    it "Insert receipt that does exist in organ",(done) ->
      expense_doc =
        price: 12.21
        currency: "MXN"
        name: "Bottle"
        quantity: 1
        receipt_id: receiptIDs[1]
        unit_id: unitIDs[0]
        organization_id: organizationIDs[0]

      organization_id = organizationIDs[0]

      insert.call {organization_id, expense_doc}, (err, res) ->
        expect(err).to.not.exist
        done()



  describe "Expenses Update", ->
    it "Invalid Currency", (done) ->
      expense_doc =
        currency: "Nlsdjf"

      organization_id = organizationIDs[0]

      expense_id = ExpenseModule.Expenses.findOne()._id

      update.call {organization_id, expense_id, expense_doc}, (err, res) ->
        expect(err).to.have.property('error', 'validation-error')
        expect(err).to.have.property('reason', 'currency_ISO_4217 cannot exceed 3 characters')
        done()

    it "Invalid unit_id",(done) ->
      expense_doc =
        unit_id: "NONO"

      organization_id = organizationIDs[0]

      expense_id = ExpenseModule.Expenses.findOne()._id

      update.call {organization_id, expense_id, expense_doc}, (err, res) ->
        expect(err).to.have.property('reason', 'unit does not belong')
        done()

    it "create unit", (done) ->
      unit_doc =
        name: faker.company.companyName()
        amount: 12
        organization_id: organizationIDs[1]

      organization_id = organizationIDs[1]

      UMethods.insert.call {organization_id, unit_doc}, (err, res) ->
        unitIDs.push res
        done()

    it "Valid unit_id but not in organization",(done) ->
      expense_doc =
        unit_id: unitIDs[1]

      organization_id = organizationIDs[0]

      expense_id = ExpenseModule.Expenses.findOne()._id

      update.call {organization_id, expense_id, expense_doc}, (err, res) ->
        expect(err).to.have.property('reason', 'unit does not belong')
        done()

    it "Valid expense_id but not in organization",(done) ->
      expense_doc =
        unit_id: unitIDs[1]

      organization_id = organizationIDs[1]

      expense_id = ExpenseModule.Expenses.findOne()._id

      update.call {organization_id, expense_id, expense_doc}, (err, res) ->
        expect(err).to.have.property('reason', 'expense does not belong')
        done()

    it "create unit", (done) ->
      unit_doc =
        name: faker.company.companyName()
        amount: 12
        organization_id: organizationIDs[0]

      organization_id = organizationIDs[0]

      UMethods.insert.call {organization_id, unit_doc}, (err, res) ->
        unitIDs.push res
        done()

    it "Valid update but with required null fields",(done) ->
      oldUnitid = ExpenseModule.Expenses.findOne().unit_id
      oldName = ExpenseModule.Expenses.findOne().name
      expense_doc =
        name: ""
        unit_id: ""
        description: faker.lorem.lines()

      organization_id = organizationIDs[0]

      expense_id = ExpenseModule.Expenses.findOne()._id

      update.call {organization_id, expense_id, expense_doc}, (err, res) ->
        expect(ExpenseModule.Expenses.findOne().unit_id).to.equal(oldUnitid)
        expect(ExpenseModule.Expenses.findOne().name).to.equal(oldName)
        expect(ExpenseModule.Expenses.findOne().description).to.exist
        done()

    it "Valid update",(done) ->
      oldUnitid = ExpenseModule.Expenses.findOne().unit_id
      expense_doc =
        name: ""
        unit_id: unitIDs[2]

      organization_id = organizationIDs[0]

      expense_id = ExpenseModule.Expenses.findOne()._id

      update.call {organization_id, expense_id, expense_doc}, (err, res) ->
        expect(ExpenseModule.Expenses.findOne().unit_id).to.not.equal(oldUnitid)
        done()



  describe "Expenses update with provider", ->

    it "Invalid provider id", (done) ->
      expense_doc =
        provider_id: "nono"


      organization_id = organizationIDs[0]

      expense_id = ExpenseModule.Expenses.findOne()._id

      update.call {organization_id, expense_id, expense_doc}, (err, res) ->
        expect(err).to.have.property('reason', 'provider does not belong')
        done()

    it "Null provider id", (done) ->
      expense = ExpenseModule.Expenses.findOne(provider_id: $exists: true)

      expect(expense.provider_id).to.exist

      expense_doc =
        provider_id: null
        name: faker.name.firstName()

      organization_id = organizationIDs[0]

      expense_id = expense._id

      update.call {organization_id, expense_id, expense_doc}, (err, res) ->
        expect(err).to.not.exist
        expect(ExpenseModule.Expenses.findOne().provider_id).to.not.exist
        done()

    it "Not auth provider id", (done) ->
      expense = ExpenseModule.Expenses.findOne()

      expense_doc =
        provider_id: providerIDs[0]
        name: faker.name.firstName()

      organization_id = organizationIDs[0]

      expense_id = expense._id

      update.call {organization_id, expense_id, expense_doc}, (err, res) ->
        expect(err).to.exist
        expect(err).to.have.property('reason', 'provider does not belong')
        done()

    it "Valid provider id", (done) ->
      expense = ExpenseModule.Expenses.findOne()
      oldP = expense.provider_id
      expense_doc =
        provider_id: providerIDs[1]
        name: faker.name.firstName()

      organization_id = organizationIDs[0]

      expense_id = expense._id

      update.call {organization_id, expense_id, expense_doc}, (err, res) ->
        expect(err).to.not.exist
        expect(ExpenseModule.Expenses.findOne().provider_id).to.not.equal(oldP)
        done()



  describe "Expenses update with receipts", ->
    it "Invalid receipt id", (done) ->
      expense_doc =
        receipt_id: "nono"

      organization_id = organizationIDs[0]

      expense_id = ExpenseModule.Expenses.findOne()._id

      update.call {organization_id, expense_id, expense_doc}, (err, res) ->
        expect(err).to.have.property('reason', 'receipt does not belong')
        done()

    it "Null receipt id", (done) ->
      expense = ExpenseModule.Expenses.findOne(receipt_id: $exists: true)

      expect(expense.receipt_id).to.exist

      expense_doc =
        receipt_id: null
        name: faker.name.firstName()

      organization_id = organizationIDs[0]

      expense_id = expense._id

      update.call {organization_id, expense_id, expense_doc}, (err, res) ->
        expect(err).to.not.exist
        expect(ExpenseModule.Expenses.findOne().receipt_id).to.not.exist
        done()

    it "Not auth receipt_id id", (done) ->
      expense = ExpenseModule.Expenses.findOne()

      expense_doc =
        receipt_id: receiptIDs[0]
        name: faker.name.firstName()

      organization_id = organizationIDs[0]

      expense_id = expense._id

      update.call {organization_id, expense_id, expense_doc}, (err, res) ->
        expect(err).to.exist
        expect(err).to.have.property('reason', 'receipt does not belong')
        done()

    it "Valid receipt id", (done) ->
      expense = ExpenseModule.Expenses.findOne()
      oldR = expense.receipt_id
      expense_doc =
        receipt_id: receiptIDs[1]
        name: faker.name.firstName()

      organization_id = organizationIDs[0]

      expense_id = expense._id

      update.call {organization_id, expense_id, expense_doc}, (err, res) ->
        expect(err).to.not.exist
        expect(ExpenseModule.Expenses.findOne().receipt_id).to.not.equal(oldR)
        done()
