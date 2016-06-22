faker = require 'faker'
Big = require 'big.js'

{ chai, assert, expect } = require 'meteor/practicalmeteor:chai'
{ Meteor } = require 'meteor/meteor'
{ Accounts } = require 'meteor/accounts-base'
{ resetDatabase } = require 'meteor/xolvio:cleaner'
{ Random } = require 'meteor/random'
{ _ } = require 'meteor/underscore'

UnitModule = require '../../imports/api/collections/units/units.coffee'
UMethods =  require '../../imports/api/collections/units/methods.coffee'
OMethods = require '../../imports/api/collections/organizations/methods.coffee'

unitIDs = []
organizationIDs = []

xdescribe "Unit loop test", ->
  before ->
    resetDatabase(null)

  it "Create user", (done) ->
    createUser(done, faker.internet.email())
  it "Create Organization", (done) ->
    createOrgan(done)

  it "create 1", (done) ->
    createUnit(done)

  it "create 2", (done) ->
    createUnit(done, unitIDs[0])

  it "create 3", (done)->
    createUnit(done, unitIDs[1])

  it "error", (done) ->
    unit_doc =
      unit_id: unitIDs[2]
    unit_id = unitIDs[0]
    organization_id = organizationIDs[0]
    UMethods.update.call {unit_id, unit_doc, organization_id}, (err, res) ->
      console.log err
      done()






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
  organization_doc =
    name: faker.company.companyName()
    email: faker.internet.email()

  OMethods.insert.call {organization_doc}, (err, res) ->
    throw err if err?
    organizationIDs.push res
    done()

createUnit = (done, unit_id) ->
  unit_doc =
    name: faker.name.firstName()
    amount: 12
    unit_id: unit_id
    organization_id: organizationIDs[0]

  UMethods.insert.call {unit_doc}, (err, res) ->
    throw err if err?
    unitIDs.push res
    done()

subscribe = (done, subto) ->
  callbacks =
    onStop: (err) ->
      throw err if err?
    onReady: () ->
      done()

  Meteor.subscribe(subto, organizationIDs[0], callbacks)
