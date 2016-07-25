

require './index.jade'

class OrganizationsIndex extends BlazeComponent
  @register 'organizations.index'

  constructor: (args) ->

  onCreated: ->
    super
    @expandedClass = new ReactiveVar('card-expand-action')
    @iconClass = new ReactiveVar('add')
    @expanded = new ReactiveVar(false)


  onExpand: =>
    @expandedClass.set('card-shrink-action')
    @iconClass.set('arrow_back')
    @expanded.set(true)

  onShrinked: =>
    @expandedClass.set('card-expand-action')
    @iconClass.set('add')
    @expanded.set(false)

  callbacks: ->
    ret =
      onExpandCallback: @onExpand
      onShinkedCallback: @onShrinked
