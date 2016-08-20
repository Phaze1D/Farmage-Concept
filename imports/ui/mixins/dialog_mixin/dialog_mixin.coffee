
{ mlists } = require '../mlist_mixin.coffee'

require './dialog_mixin.jade'


class DialogMixin extends BlazeComponent

  onCreated: ->
    @showDialog = new ReactiveVar(false)
    @clists = new ReactiveDict()
    @subscription = new ReactiveVar('')
    @many = new ReactiveVar('')
    @parent = new ReactiveVar('')
    @parentID = new ReactiveVar('')


  dialogCB: ->
    ret =
      showClick: =>
        @showDialog.set true
      hideClick: =>
        @showDialog.set false

      beforeHide: @onCloseDialogCallback


  onShowDialog: (event) ->
    resourcesB = $(event.currentTarget).find('.js-dialog-b')
    @subscription.set resourcesB.attr('data-sub')
    @parent.set(resourcesB.attr('data-parent')) if resourcesB.attr('data-parent')?
    @parentID.set(resourcesB.attr('data-parentid')) if resourcesB.attr('data-parent')?
    if resourcesB.attr('data-many') is 'true'
      @many.set true
    else
      @many.set false

    $(@find('.js-open-dialog')).trigger('click')


  currentList: (sub) ->
    sub = @subscription.get() + @parentID.get() unless sub?
    cl = @clists.get(sub)
    return cl if cl?
    return []


  onCloseDialogCallback: =>
    list = []
    sub = @subscription.get()
    $(".list-item[selected='true']").each ->
      item_id = $(@).attr('data-id')
      list.push mlists[sub].findOne item_id

    @clists.set @subscription.get() + @parentID.get(), list

    if @mixinParent().onCloseDialogCallback?
      @mixinParent().onCloseDialogCallback()




  events: ->[
    'click .js-show-d': @onShowDialog
  ]


module.exports = DialogMixin
