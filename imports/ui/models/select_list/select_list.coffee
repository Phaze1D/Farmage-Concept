
{ mlists } = require '../../mixins/mlist_mixin.coffee'

require './select_list.jade'


class SelectList extends BlazeComponent
  @register 'selectList'

  onCreated: ->
    super
    organization_id = FlowRouter.getParam 'organization_id'
    @sitem = {}
    @autorun =>
      @subscribe @data().subscription, organization_id, @data().parent, @data().parent_id,
        onStop: (err) ->
          console.log "sub stop #{err}"
        onReady: ->



  title: ->
    @data().subscription.charAt(0).toUpperCase() +
    @data().subscription.slice(1);


  items: ->
    mlists[@data().subscription].find()

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
