
{ parent } = require '../../mixins/mlist_mixin.coffee'
OrganizationModule = require '../../../api/collections/organizations/organizations.coffee'


require './select_list.jade'


class SelectList extends BlazeComponent
  @register 'selectList'

  onCreated: ->
    super
    organization_id = FlowRouter.getParam 'organization_id'
    @tabs = if @data().tabSubs.length > 0 then true else false
    @searchValue = new ReactiveVar('')
    @canLoadMore = true

    @autorun =>
      if @tabs
        for tab in @data().tabSubs
          @page = Meteor.subscribeWithPagination tab.subscription, organization_id, 'organization', organization_id, @searchValue.get(), 5,
                      onStop: (err) ->
                        console.log "sub stop #{err}"
                      onReady: =>

      else
        @page = Meteor.subscribeWithPagination @data().subscription, organization_id, @data().parent, @data().parent_id, @searchValue.get(), 1,
                  onStop: (err) ->
                    console.log "sub stop #{err}"
                  onReady: =>




  title: (subscription)->
    subscription.charAt(0).toUpperCase() + subscription.slice(1);

  items: (subscription) ->
    if subscription? && @data().parent? && @data().parent.length > 0
      parent[@data().parent].findOne(@data().parent_id)[subscription](null, @searchValue.get())
    else if subscription?

      organization_id = FlowRouter.getParam 'organization_id'
      OrganizationModule.Organizations.findOne(organization_id)[subscription](null, @searchValue.get())

  itemIsSelected: (item_id, subscription, parent_id) ->
    if @data().clists.get(subscription + parent_id)?
      return true for item in @data().clists.get(subscription + parent_id) when item._id is item_id
    return false

  onShowSearch: (event) ->
    $(event.currentTarget).css(display: 'none')
    $('.search-input .pinput').focus()
    sid = $(@find('.search-input-div'))
    if sid.innerWidth() <= 0

      sid.velocity
        p:
          width: '100%'
        o:
          duration: 250
          easing: 'ease-in-out'


  onHideSearch: (event) ->
    $(@find('.js-search-icon')).css(display: 'flex')
    sid = $(@find('.search-input-div'))
    sid.velocity
      p:
        width: '0'
      o:
        duration: 250
        easing: 'ease-in-out'

  selector: (subscription)->
    subscription + 'Selector'

  selectorData: (item, subscription) ->
    parent_id = if item.product_id? then item.product_id else @data().parent_id
    ret =
      item:item
      isChecked: @itemIsSelected(item._id, subscription, parent_id)
      many: @data().many


  moveOutLeft: (tar) ->
    tar.velocity
      p:
        left: '-100%'
      o:
        duration: 250
        easing: 'ease-in-out'

  moveOutRight: (tar) ->
    tar.velocity
      p:
        left: '100%'
      o:
        duration: 250
        easing: 'ease-in-out'

  moveIn: (tar) ->
    tar.velocity
      p:
        left: '0'
      o:
        duration: 250
        easing: 'ease-in-out'


  onTabClick: (event) ->
    tar = $(event.currentTarget)
    unless tar.hasClass('active')
      tarItems = $(".tab-items[data-sub='#{tar.attr('data-sub')}']")
      previous = $('.active')
      previous.removeClass('active')
      if tarItems.position().left > 0
        @moveOutLeft($(".tab-items[data-sub='#{previous.attr('data-sub')}']"))
      else
        @moveOutRight($(".tab-items[data-sub='#{previous.attr('data-sub')}']"))


      tar.toggleClass('active')
      @moveIn(tarItems)

      leftPer = (tar.position().left/$('.tab-panel').width()) * 100

      $('.tab-underline').velocity
        p:
          left: "#{leftPer}%"
        o:
          duration: 250
          easing: 'ease-in-out'



  onSearch: (event) ->
    event.preventDefault()
    @searchValue.set $(@find '.search-input .pinput').val()


  onScrollList: (event) ->
    yPosition = event.target.scrollTop
    if yPosition + event.target.clientHeight is event.target.scrollHeight
      if @page.ready()
        console.log 'loadmaore'
        @page.loadNextPage()


  ready: (subscription)->
    if subscription? && @page.ready()
      count = @items(subscription).count()
      if @previous is count
        @canLoadMore = false
      else
        @canLoadMore = true
        @previous = count

  events: ->
    super.concat
      'click .js-search-icon': @onShowSearch
      'click .js-cross-search': @onHideSearch
      'click .js-tab': @onTabClick
      'submit .js-search-form': @onSearch
      'scroll .items': @onScrollList
      'scroll .tab-items': @onScrollList
