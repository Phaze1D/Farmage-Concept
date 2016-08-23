
require './selector.jade'

class IngredientSelector extends BlazeComponent
  @register 'ingredientsSelector'

  constructor: (args) ->
    # body...

  onCreated: ->
    super
    @data().isChecked = new ReactiveVar(@data().isChecked)

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
