
require './selector.jade'

class YieldSelector extends BlazeComponent
  @register 'yieldsSelector'

  constructor: (args) ->
    # body...

  onCreated: ->
    super
    @data().isChecked = new ReactiveVar(@data().isChecked)

  date: (date)->
    months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
    "#{months[date.getMonth()]} #{date.getDate()}, #{date.getFullYear()}"

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

  resourse: ->
    @data().item.ingredient().fetch()[0]

  identifer: ->
    if @data().item.name?
      @data().item.name
    else
      @data().item._id

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
