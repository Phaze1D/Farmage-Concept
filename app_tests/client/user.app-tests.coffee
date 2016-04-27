faker = require 'faker'

{ chai, assert, expect } = require 'meteor/practicalmeteor:chai'
{ Meteor } = require 'meteor/meteor'
{ Accounts } = require 'meteor/accounts-base'
{ resetDatabase } = require 'meteor/xolvio:cleaner'
{ _ } = require 'meteor/underscore'

{ Organizations } =  require '../../imports/api/collections/organizations/organizations.coffee'

{ inviteUser } = require '../../imports/api/collections/users/methods.coffee'
{ insert } = require '../../imports/api/collections/organizations/methods.coffee'


xdescribe 'User Full App Tests Client', () ->

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

  sharedEmail = faker.internet.email()

  describe 'User sign up flow', () ->

    after( (done) ->
      Meteor.logout( (err) ->
        done()
      )
      return
    )

    it 'User simple schema fail validations', (done) ->
      expect(Meteor.user()).to.not.exist

      doc =
        email: faker.internet.email()
        password: '1234568878'

      Accounts.createUser doc, (err) ->
        expect(err).to.have.property('error', 'validation-error');
        done()
        return
      return

    it 'User simple schema success validations', (done) ->

      expect(Meteor.user()).to.not.exist
      doc =
        email: sharedEmail
        password: '12345678'
        profile:
          first_name: faker.name.firstName()
          last_name: faker.name.lastName()

      Accounts.createUser doc, (error) ->
        expect(error).to.not.exist
        Meteor.logout( (err) ->
          done()
        )
        return
      return

    it 'User simple schema duplicate emails', (done) ->

      expect(Meteor.user()).to.not.exist
      doc =
        email: sharedEmail
        password: '123123123'
        profile:
          first_name: faker.name.firstName()
          last_name: faker.name.lastName()

      Accounts.createUser doc, (error) ->
        expect(error).to.have.property('reason', 'Email already exists.')
        done()
        return
      return



  describe 'Invite user to organization', ->

    after( (done) ->
      Meteor.logout( (err) ->
        done()
      )
      return
    )

    it 'Invite nonexistent user to new organization not logged in', (done) ->
      expect(Meteor.user()).to.not.exist


      invited_user_doc =
        emails:
          [
            address: faker.internet.email()
          ]
        profile:
          first_name: faker.name.firstName()

      organization_id = 'Dont Own'

      permission =
        units_manager: true

      expect ->
        inviteUser.call {invited_user_doc, organization_id, permission}
      .to.Throw('notLoggedIn')

      doc =
        email: faker.internet.email()
        password: '123123123'
        profile:
          first_name: faker.name.firstName()
          last_name: faker.name.lastName()

      Accounts.createUser doc, (error) ->
        expect(error).to.not.exist
        done()

      return

    it 'Invite nonexistent user to new organization not Auth', (done) ->
      expect(Meteor.user()).to.exist

      invited_user_doc =
        emails:
          [
            address: faker.internet.email()
          ]
        profile:
          first_name: faker.name.firstName()

      organization_id = 'AijWjNwoih4aB7mLK'

      permission =
        units_manager: true

      inviteUser.call {invited_user_doc , organization_id, permission}, (err, res) ->
        expect(err).to.have.property('error', 'notAuthorized');
        done()

      return


    shared_organization =
    it 'Invite nonexistent user to new organization', (done) ->
      expect(Meteor.user()).to.exist

      organ_doc =
        name: faker.company.companyName()
        email: faker.internet.email()

      insert.call organ_doc, (err, res) ->
        expect(err).to.not.exist
        return

      shared_organization = Organizations.findOne()._id

      invited_user_doc =
        emails:
          [
            address: faker.internet.email()
          ]
        profile:
          first_name: faker.name.firstName()

      organization_id = shared_organization

      permission =
        units_manager: true

      currentUser = Meteor.userId()

      inviteUser.call {invited_user_doc, organization_id, permission}, (err, res) ->
        expect(err).to.not.exist
        expect(currentUser).to.equal(Meteor.userId())
        done()


      return

    it 'Invite existent user to organization' , (done) ->
      expect(Meteor.user()).to.exist

      invited_user_doc =
        emails:
          [
            address: sharedEmail
          ]
        profile:
          first_name: faker.name.firstName()

      organization_id = shared_organization

      permission =
        units_manager: true

      inviteUser.call {invited_user_doc, organization_id, permission}, (err, res) ->
        expect(err).to.not.exist
        done()


    it 'Invite without correct permission', (done) ->
      Meteor.loginWithPassword sharedEmail, '12345678', (err) ->
        expect(err).to.not.exist
        invited_user_doc =
          emails:
            [
              address: faker.internet.email()
            ]
          profile:
            first_name: faker.name.firstName()

        organization_id = shared_organization

        permission =
          units_manager: true

        inviteUser.call {invited_user_doc, organization_id, permission}, (err, res) ->
          expect(err).to.have.property('error','notOwner')
          done()



  describe 'User Login flow', ->

    before( (done) ->
      doc =
        email: 'footdavid@hotmail.com'
        password: '12345678'
        profile:
          first_name: faker.name.firstName()
          last_name: faker.name.lastName()

      Accounts.createUser doc, (error) ->
        Meteor.logout( (err) ->
          done()
        )
      return
    )

    it 'Invalid email', (done) ->

      expect(Meteor.user()).to.not.exist

      Meteor.loginWithPassword 'footdavidmomo@hotmail.com', '12345678', (err) ->
        expect(err).to.have.property('reason', 'User not found')
        done()

    it 'Invalid Password', (done) ->
      expect(Meteor.user()).to.not.exist

      Meteor.loginWithPassword 'footdavid@hotmail.com', '12345asdf', (err) ->
        expect(err).to.have.property('reason', 'Incorrect password')
        done()

    it 'Correct User', (done) ->
      expect(Meteor.user()).to.not.exist

      Meteor.loginWithPassword 'footdavid@hotmail.com', '12345678', (err) ->
        expect(err).to.not.exist
        expect(Meteor.user()).to.exist
        done()
