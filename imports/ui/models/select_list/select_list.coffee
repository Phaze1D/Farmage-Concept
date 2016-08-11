require './select_list.jade'

CustomerModule = require '../../../api/collections/customers/customers.coffee'
ExpenseModule = require '../../../api/collections/expenses/expenses.coffee'
ProviderModule = require '../../../api/collections/providers/providers.coffee'
YieldModule = require '../../../api/collections/yields/yields.coffee'
UnitModule = require '../../../api/collections/units/units.coffee'
ProductModule = require '../../../api/collections/products/products.coffee'
InventoryModule = require '../../../api/collections/inventories/inventories.coffee'
EventModule = require '../../../api/collections/events/events.coffee'
SellModule = require '../../../api/collections/sells/sells.coffee'
IngredientModule = require '../../../api/collections/ingredients/ingredients.coffee'

lists = {}
lists.ingredients = IngredientModule.Ingredients


class SelectList extends BlazeComponent
  @register 'selectList'

  onCreated: ->
    organization_id = FlowRouter.getParam 'organization_id'
    @autorun =>
      @subscribe @data().subscription, organization_id,
        onStop: (err) ->
          console.log "sub stop #{err}"
        onReady: ->


  title: ->
    @data().subscription.charAt(0).toUpperCase() +
    @data().subscription.slice(1);


  items: ->
    lists[@data().subscription].find()



  onShowSearch: (event) ->
    $('.search-input .pinput').focus()
    sid = $(@find('.search-input-div'))
    if sid.innerWidth() <= 0
      sid.velocity
        p:
          width: '250px'
        o:
          duration: 250
          easing: 'ease-in-out'

  onHideSearch: (event) ->
    sid = $(@find('.search-input-div'))
    sid.velocity
      p:
        width: '0'
      o:
        duration: 250
        easing: 'ease-in-out'


  onItemClick: (event) ->
    targ = $(event.currentTarget)
    targ.find('.js-checkbox').trigger('click')
    if targ.attr('selected')
      targ.attr('selected', false)
      targ.css 'color': ''
      targ.find('.circle-image').css border: ''
    else
      targ.attr('selected', true)
      targ.css 'color': 'darkblue'
      targ.find('.circle-image').css border: '1px solid darkblue'

  events: ->
    super.concat
      'click .js-search-icon': @onShowSearch
      'click .js-cross-search': @onHideSearch
      'click .js-list-item': @onItemClick
