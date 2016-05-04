faker = require 'faker'

{ chai, assert, expect } = require 'meteor/practicalmeteor:chai'
{ Meteor } = require 'meteor/meteor'
{ Accounts } = require 'meteor/accounts-base'
{ resetDatabase } = require 'meteor/xolvio:cleaner'
{ _ } = require 'meteor/underscore'

UnitModule = require '../../imports/api/collections/units/units.coffee'
OrganizationModule = require '../../imports/api/collections/organizations/organizations.coffee'

{
  insert
  update
} = require '../../imports/api/collections/units/methods.coffee'

{ inviteUser } = require '../../imports/api/collections/users/methods.coffee'
OMethods = require '../../imports/api/collections/organizations/methods.coffee'


describe 'Units Full App Test Client', () ->

  describe 'Insert Unit', () ->
    it 'Insert not logged in', () ->

    it 'Insert not valid', () ->

    it 'Insert not auth', () ->

    it 'Insert without permission', () ->

    it 'Insert success', () ->

    it 'Insert unique name failed', () ->

    it 'Insert with non unique name but different organization', () ->

    it 'Insert with non unique name and organization', () ->


  describe 'Update Unit', () ->
    it 'Update not logged in', () ->

    it 'Update not valid', () ->

    it 'Update not auth', () ->

    it 'Update without permission', () ->

    it 'Update success', () ->

    it 'Update with same name', () ->

    it 'Update with non unique name but different organization', () ->

    it 'Update with non unique name and organization', () ->


  describe 'Insert with Parent', () ->
    it 'Insert nonexisent parent', () ->

    it 'Insert exisent parent but not to organ', () ->

    it 'Insert parent with having same ID', () ->

    it 'Insert parent success', () ->


  describe 'Update with Parent', () ->
    it 'Update nonexisent parent', () ->

    it 'Update exisent parent but not to organ', () ->

    it 'Update parent with having same ID', () ->

    it 'Update parent success', () ->
