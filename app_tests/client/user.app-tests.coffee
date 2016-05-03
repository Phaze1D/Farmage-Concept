faker = require 'faker'

{ chai, assert, expect } = require 'meteor/practicalmeteor:chai'
{ Meteor } = require 'meteor/meteor'
{ Accounts } = require 'meteor/accounts-base'
{ resetDatabase } = require 'meteor/xolvio:cleaner'
{ _ } = require 'meteor/underscore'

{ Organizations } =  require '../../imports/api/collections/organizations/organizations.coffee'

{
  inviteUser
  updatePermission
  removeFromOrganization
  updateProfile
} = require '../../imports/api/collections/users/methods.coffee'

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
        owner: false
        editor: false
        expenses_manager: false
        sells_manager: false
        units_manager: false
        inventories_manager: true
        users_manager: false


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
          owner: false
          editor: false
          expenses_manager: false
          sells_manager: false
          units_manager: false
          inventories_manager: true
          users_manager: false

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
        owner: false
        editor: false
        expenses_manager: false
        sells_manager: false
        units_manager: false
        inventories_manager: true
        users_manager: false

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
        owner: false
        editor: false
        expenses_manager: false
        sells_manager: false
        units_manager: false
        inventories_manager: true
        users_manager: false

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
          owner: false
          editor: false
          expenses_manager: false
          sells_manager: false
          units_manager: false
          inventories_manager: true
          users_manager: false

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

    after( (done) ->
      Meteor.logout( (err) ->

      )
      @timeout(20000)
      setTimeout(done, 10000)
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



  describe 'User update permission', ->

    before( (done) ->
      callbacks =
        onStop: () ->
        onReady: () ->
          done()

      Meteor.subscribe("organizations", callbacks)
    )


    it 'Create new user', (done) ->
      doc =
        email: 'example@hotmail.com'
        password: '12345678'
        profile:
          first_name: faker.name.firstName()
          last_name: faker.name.lastName()

      Accounts.createUser doc, (err) ->
        expect(err).to.not.exist
        done()

    organization_id00 = ''
    it 'Create organization', (done) ->
      organ_doc =
        name: faker.company.companyName()
        email: faker.internet.email()

      insert.call organ_doc, (err, res) ->
        expect(err).to.not.exist
        organization_id00 = res
        done()


    it 'Log Out and create new user log out again', (done) ->
      Meteor.logout((err) ->
        expect(err).to.not.exist
        doc =
          email: 'example2@hotmail.com'
          password: '12345678'
          profile:
            first_name: faker.name.firstName()
            last_name: faker.name.lastName()

        Accounts.createUser doc, (err) ->
          expect(err).to.not.exist
          Meteor.logout( (err) ->
            expect(err).to.not.exist
            done()
          )
      )

    it 'Login and invite user', (done) ->
      Meteor.loginWithPassword 'example@hotmail.com', '12345678', (err) ->
        expect(err).to.not.exist
        invited_user_doc =
          emails:
            [
              address: 'example2@hotmail.com'
            ]
          profile:
            first_name: faker.name.firstName()

        organization_id = organization_id00

        permission =
          owner: false
          editor: false
          expenses_manager: false
          sells_manager: false
          units_manager: false
          inventories_manager: true
          users_manager: false

        inviteUser.call {invited_user_doc, organization_id, permission}, (err, res) ->
          expect(err).to.not.exist
          done()


    it 'Log out and login with non auth user', (done) ->
      Meteor.logout( (err) ->
        expect(err).to.not.exist
        Meteor.loginWithPassword 'example2@hotmail.com', '12345678', (err) ->
          expect(err).to.not.exist
          done()
      )


    updateUser = ''
    it 'Is not owner or user manager but belongs to organ', (done) ->
      updateUser = Meteor.userId()
      update_user_id = updateUser
      organization_id = organization_id00
      permission =
        owner: true
        editor: false
        expenses_manager: false
        sells_manager: false
        units_manager: false
        inventories_manager: true
        users_manager: false

      updatePermission.call {update_user_id, organization_id, permission}, (err, res) ->
        expect(err).to.have.property('error', 'notUserManager')
        done()


    it 'Log out and login with auth user', (done) ->
      Meteor.logout( (err) ->
        expect(err).to.not.exist
        Meteor.loginWithPassword 'example@hotmail.com', '12345678', (err) ->
          expect(err).to.not.exist
          done()
      )

    it 'Is auth user update permission other user', (done) ->
      expect(Organizations.findOne().hasUser(updateUser).permission.owner).to.equal(false)
      update_user_id = updateUser
      organization_id = organization_id00
      permission =
        owner: true
        editor: false
        expenses_manager: false
        sells_manager: false
        units_manager: false
        inventories_manager: true
        users_manager: false

      updatePermission.call {update_user_id, organization_id, permission}, (err, res) ->
        expect(err).to.not.exist
        expect(Organizations.findOne().hasUser(updateUser).permission.owner).to.equal(true)
        done()

    it 'Is auth user update permission same user', (done) ->
      expect(Organizations.findOne().hasUser(Meteor.userId()).permission.owner).to.equal(true)
      update_user_id = Meteor.userId()
      organization_id = organization_id00
      permission =
        owner: false
        editor: false
        expenses_manager: false
        sells_manager: false
        units_manager: false
        inventories_manager: true
        users_manager: true

      updatePermission.call {update_user_id, organization_id, permission}, (err, res) ->
        expect(err).to.have.property('error', 'notAuthorized')
        done()

    it 'Is auth user update permission other user', (done) ->
      expect(Organizations.findOne().hasUser(updateUser).permission.owner).to.equal(true)
      update_user_id = updateUser
      organization_id = organization_id00
      permission =
        owner: false
        editor: false
        expenses_manager: false
        sells_manager: false
        units_manager: false
        inventories_manager: true
        users_manager: true

      updatePermission.call {update_user_id, organization_id, permission}, (err, res) ->
        expect(err).to.not.exist
        expect(Organizations.findOne().hasUser(updateUser).permission.owner).to.equal(false)
        done()

    it 'Log out and login with auth user', (done) ->
      Meteor.logout( (err) ->
        expect(err).to.not.exist
        Meteor.loginWithPassword 'example2@hotmail.com', '12345678', (err) ->
          expect(err).to.not.exist
          done()
      )

    it 'Is user manager only, setting owner ', (done) ->
      expect(Organizations.findOne().hasUser(Meteor.userId()).permission.owner).to.equal(false)
      update_user_id = Meteor.userId()
      organization_id = organization_id00
      permission =
        owner: true
        editor: false
        expenses_manager: false
        sells_manager: false
        units_manager: false
        inventories_manager: true
        users_manager: true

      updatePermission.call {update_user_id, organization_id, permission}, (err, res) ->
        expect(err).to.have.property('error', 'notOwner')
        done()


    it 'Is user manager only, setting other', (done) ->
      update_user_id = Meteor.userId()
      organization_id = organization_id00
      permission =
        owner: false
        editor: true
        expenses_manager: false
        sells_manager: false
        units_manager: false
        inventories_manager: true
        users_manager: true

      updatePermission.call {update_user_id, organization_id, permission}, (err, res) ->
        expect(err).to.not.exist
        expect(Organizations.findOne().hasUser(Meteor.userId()).permission.editor).to.equal(true)
        done()


    it 'Log out and login with auth user', (done) ->
      Meteor.logout( (err) ->
        expect(err).to.not.exist
        Meteor.loginWithPassword 'example@hotmail.com', '12345678', (err) ->
          expect(err).to.not.exist
          done()
      )

    organization_id01 = ''
    it 'Create new organization', (done) ->
      organ_doc =
        name: faker.company.companyName()
        email: faker.internet.email()

      insert.call organ_doc, (err, res) ->
        expect(err).to.not.exist
        organization_id01 = res
        done()

    it 'Update nonexistent user of organization', (done) ->
      this.timeout(50000);
      setTimeout(done, 10000);

      update_user_id = updateUser
      organization_id = organization_id01
      permission =
        owner: true
        editor: false
        expenses_manager: false
        sells_manager: false
        units_manager: false
        inventories_manager: true
        users_manager: false

      updatePermission.call {update_user_id, organization_id, permission}, (err, res) ->
        expect(err).to.have.property('error','userNotInOrganization')



    it 'Log out and login with non auth user', (done) ->
      updateUser = Meteor.userId()
      Meteor.logout( (err) ->
        expect(err).to.not.exist
        Meteor.loginWithPassword 'example2@hotmail.com', '12345678', (err) ->
          expect(err).to.not.exist
          done()
      )

    it 'Update existent user of non auth organization', (done) ->

      update_user_id = updateUser
      organization_id = organization_id01
      permission =
        owner: true
        editor: false
        expenses_manager: false
        sells_manager: false
        units_manager: false
        inventories_manager: true
        users_manager: false

      updatePermission.call {update_user_id, organization_id, permission}, (err, res) ->
        expect(err).to.have.property('error','notAuthorized')
        done()



  describe 'Remove user from organization', ->

    it 'Log out and login with owner', (done) ->
      Meteor.logout( (err) ->
        expect(err).to.not.exist
        Meteor.loginWithPassword 'example@hotmail.com', '12345678', (err) ->
          expect(err).to.not.exist
          done()
      )

    it 'Remove nonexistent user', (done) ->

      update_user_id = "nonono"
      organization_id = Organizations.findOne()._id

      removeFromOrganization.call {update_user_id, organization_id}, (err, res) ->
        expect(err).to.have.property('error', 'userNotInOrganization')
        done()

    it 'Remove existent user but not in organ', (done) ->

      update_user_id = "nonono"
      organization_id = Organizations.findOne()._id
      Organizations.find().forEach (doc) ->
        if doc.ousers.length > 1
          for ouser in doc.ousers
            if ouser.user_id isnt Meteor.userId()
              update_user_id = ouser.user_id
        else
          organization_id = doc._id

      removeFromOrganization.call {update_user_id, organization_id}, (err, res) ->
        expect(err).to.have.property('error', 'userNotInOrganization')
        done()


    it 'Try to remove owner', (done) ->

      update_user_id = Meteor.userId()
      organization_id = Organizations.findOne()._id

      removeFromOrganization.call {update_user_id, organization_id}, (err, res) ->
        expect(err).to.have.property('error', 'notAuthorized')
        expect(err).to.have.property('reason', 'an owner cannot remove themselves')
        done()


    it 'Remove correct', (done) ->

      update_user_id = "nonono"
      organization_id = Organizations.findOne()._id
      length = ''
      Organizations.find().forEach (doc) ->
        if doc.ousers.length > 1
          organization_id = doc._id
          length = doc.ousers.length
          for ouser in doc.ousers
            if ouser.user_id isnt Meteor.userId()
              update_user_id = ouser.user_id

      removeFromOrganization.call {update_user_id, organization_id}, (err, res) ->
        doc = Organizations.findOne(organization_id)
        expect(length).to.be.above(doc.ousers.length)
        expect(doc.hasUser(update_user_id)).to.not.exist
        done()



  describe 'Updating User profile', ->

    before( (done) ->
      doc =
        email: 'footdavid@hotmail.com'
        password: '12345678'
        profile:
          first_name: faker.name.firstName()
          last_name: faker.name.lastName()

      Accounts.createUser doc, (error) ->
        done()
    )

    it 'Invalid profile doc', (done) ->
      expect(Meteor.user()).to.exist

      profile_doc =
          nono: faker.name.firstName()
          last_name: faker.name.lastName()


      updateProfile.call {profile_doc}, (err, res) ->
        expect(err).to.have.property('error', 'validation-error')
        done()

    it 'Valid profile doc update', (done) ->
      expect(Meteor.user()).to.exist

      firstName = Meteor.user().profile.first_name

      profile_doc =
          first_name: faker.name.firstName()
          last_name: faker.name.lastName()


      updateProfile.call {profile_doc}, (err, res) ->
        expect(err).to.not.exist
        expect(Meteor.user().profile.first_name).to.not.equal(firstName)
        done()


    it 'Valid profile doc with address update', (done) ->
      expect(Meteor.user()).to.exist

      firstName = Meteor.user().profile.first_name
      address =
        street: faker.address.streetAddress()
        city: faker.address.city()
        state: faker.address.state()
        zip_code: faker.address.zipCode()
        country: faker.address.country()

      profile_doc =
          first_name: faker.name.firstName()
          last_name: faker.name.lastName()
          addresses: [
            address
          ]


      updateProfile.call {profile_doc}, (err, res) ->
        expect(err).to.not.exist
        expect(Meteor.user().profile.first_name).to.not.equal(firstName)
        expect(Meteor.user().profile.addresses.length).to.be.at.least(1)
        console.log Meteor.user()
        done()

    it 'Valid profile doc with invalid address update', (done) ->
      expect(Meteor.user()).to.exist

      firstName = Meteor.user().profile.first_name
      address =
        city: faker.address.city()
        state: faker.address.state()
        zip_code: faker.address.zipCode()
        country: faker.address.country()

      profile_doc =
          first_name: faker.name.firstName()
          last_name: faker.name.lastName()
          addresses: [
            address
          ]

      updateProfile.call {profile_doc}, (err, res) ->
        expect(err).to.have.property('error','validation-error')
        done()
