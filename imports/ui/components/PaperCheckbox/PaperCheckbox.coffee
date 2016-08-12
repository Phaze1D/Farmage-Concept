require './PaperCheckbox.tpl.jade'


class PaperCheckbox extends BlazeComponent
  @register 'PaperCheckbox'

  onCreated: ->
    super
    @color = new ReactiveVar('black')
    if @data().checked?
      @color.set @data().fcolor

  onClick: (event) ->
    event.stopImmediatePropagation()
    if @data().clickCallback.callback?
      @data().clickCallback.callback(event)
    tar = $(event.currentTarget).find('.checkbox-mark')
    tar.toggleClass('checked')
    if @color.get() isnt @data().fcolor
      @color.set @data().fcolor
    else
      @color.set 'black'



  events: ->
    super.concat
      'click .js-checkbox': @onClick
