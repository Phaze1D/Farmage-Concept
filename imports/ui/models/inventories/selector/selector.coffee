
require './selector.jade'

class InventorySelector extends BlazeComponent
  @register 'inventoriesSelector'

  constructor: (args) ->
    # body...

  onCreated: ->
    super
    @data().isChecked = new ReactiveVar(@data().isChecked)

  date: (date)->
    months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
    "#{months[date.getMonth()]} #{date.getDate()}, #{date.getFullYear()}"

  product: ->
    @data().item.product().fetch()[0]

  identifer: ->
    if @data().item.name?
      @data().item.name
    else
      @data().item._id

  onItemClick: (event) ->
    if @data().many
      $(event.currentTarget).find('.js-checkbox').trigger('click')
    else

      if $(event.currentTarget).find('.radio-mark').hasClass('checked')
        $('.radio-mark.checked').trigger('click')
      else
        $('.radio-mark.checked').trigger('click')
        $(event.currentTarget).find('.js-radio').trigger('click')


  color: ->
    if @data().isChecked
      return 'darkblue'
    else
      return ''

  onItemClickCallback: ->
    ret =
      callback: (event) =>
        targ = $(@find '.js-list-item')
        if targ.attr('selected')
          @data().isChecked.set(false)
        else
          @data().isChecked.set(true)



  events: ->
    super.concat
      'click .js-list-item':@onItemClick
