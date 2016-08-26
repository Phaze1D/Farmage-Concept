
{ mlists } = require '../mlist_mixin.coffee'

require './dialog_mixin.jade'


class DialogMixin extends BlazeComponent

  onCreated: ->
    @showDialog = new ReactiveVar(false)
    @clists = new ReactiveDict()
    @tabs = new ReactiveVar([])
    @subscription = new ReactiveVar('')
    @many = new ReactiveVar('')
    @parent = new ReactiveVar('')
    @parentID = new ReactiveVar('')


  dialogCB: ->
    ret =
      showClick: =>
        @showDialog.set true
      hideClick: @onHideCallback
      beforeHide: @onCloseDialogCallback

  getParent: ->
    @parent.get()

  getParentID: ->
    @parentID.get()

  onShowDialog: (event) ->
    @parent.set('')
    @parentID.set('')
    @tabs.set([])
    resourcesB = $(event.currentTarget).find('.js-dialog-b')

    @clists.clear() if resourcesB.attr('data-reset')?
    @subscription.set resourcesB.attr('data-sub')

    if resourcesB.attr('tabs')?
      @tabs.set [
        {
          subscription: resourcesB.attr('data-tab1')
          active: 'active'
          left: 0
        },
        {
          subscription: resourcesB.attr('data-tab2')
          active: ''
          left: '100%'
        }
      ]


    @parent.set(resourcesB.attr('data-parent')) if resourcesB.attr('data-parent')?
    @parentID.set(resourcesB.attr('data-parentid')) if resourcesB.attr('data-parent')?
    if resourcesB.attr('data-many') is 'true'
      @many.set true
    else
      @many.set false

    $(@find('.js-open-dialog')).trigger('click')

    if @mixinParent().onShowDialog?
      @mixinParent().onShowDialog()


  currentList: (sub) ->
    sub = @subscription.get() + @parentID.get() unless sub?
    cl = @clists.get(sub)
    return cl if cl?
    return []

  clistsDict: ->
    @clists

  onHideCallback: =>
    @showDialog.set false
    if @mixinParent().onHideCallback?
      @mixinParent().onHideCallback()

  onCloseDialogCallback: =>

    if @tabs.get().length > 0
      @closeWithTabs()
    else
      @closeWithSubscription()

    if @mixinParent().onCloseDialogCallback?
      @mixinParent().onCloseDialogCallback()


  closeWithTabs: ->
    tabList = {}
    tabList[@tabs.get()[0].subscription] = []
    tabList[@tabs.get()[1].subscription] = []

    $(".list-item[selected='true']").each ->
      item_id = $(@).attr('data-id')
      sub = $(@).closest('.tab-items').attr('data-sub')
      tabList[sub].push mlists[sub].findOne item_id

    for key, value of tabList
      @clists.set(key, value)


  closeWithSubscription: ->
    list = []
    sub = @subscription.get()
    $(".list-item[selected='true']").each ->
      item_id = $(@).attr('data-id')
      list.push mlists[sub].findOne item_id

    @clists.set @subscription.get() + @parentID.get(), list



  events: ->[
    'click .js-show-d': @onShowDialog
  ]


module.exports = DialogMixin
