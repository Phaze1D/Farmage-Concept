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
lists.providers = ProviderModule.Providers
lists.units = UnitModule.Units


class SelectList extends BlazeComponent
  @register 'selectList'

  onCreated: ->
    organization_id = FlowRouter.getParam 'organization_id'
    @sitem = {}
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

  itemIsSelected: (item_id) ->
    return true for item in @data().currentList when item._id is item_id
    return false

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

  selector: ->
    @data().subscription + 'Selector'

  selectorItem: (item) ->
    @sitem = item
    true

  selectorData: ->
    ret =
      item:@sitem
      isChecked: @itemIsSelected(@sitem._id)


  events: ->
    super.concat
      'click .js-search-icon': @onShowSearch
      'click .js-cross-search': @onHideSearch
