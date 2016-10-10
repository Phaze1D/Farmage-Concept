require './PaperRadio.tpl.jade'


class PaperRadio extends BlazeComponent
  @register 'PaperRadio'

  onCreated: ->
    super
    @color = new ReactiveVar('black')
    if @data().checked
      @data().checked = 'checked'
      @color.set @data().fcolor
    else
      @data().checked = ''

  onClick: (event) ->
    event.stopImmediatePropagation()
    tar = $(event.currentTarget).find('.radio-mark')

    if $(event.currentTarget).find('.radio-mark').hasClass('checked')
      $('.radio-mark.checked').not(tar).trigger('click')
    else
      $('.radio-mark.checked').not(tar).trigger('click')

    if @data().clickCallback.callback?
      @data().clickCallback.callback(event)


    tar.toggleClass('checked')
    if @color.get() isnt @data().fcolor
      @color.set @data().fcolor
    else
      @color.set 'black'



  events: ->
    super.concat
      'click .js-radio': @onClick
