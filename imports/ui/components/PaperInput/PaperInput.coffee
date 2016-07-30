require './PaperInput.tpl.jade'


class PaperInput extends BlazeComponent
  @register 'PaperInput'

  constructor: (args) ->

  onCreated: ->
    super
    @color = new ReactiveVar ''
    @colorL = new ReactiveVar ''
    @underline = new ReactiveVar ''
    @float = new ReactiveVar ''
    @charCount = new ReactiveVar "0/#{@data().charMax}"
    @textarea = @data().type is 'textarea'


  onRendered: ->
    $(@find('.pinput')).trigger('input')
    $(@find('.pinput')).trigger('focusout')
    $(@find('textarea')).textareaAutoSize();
    @onInput @find('.pinput')


  onFocusIn: (event) ->
    @underline.set('highlight')
    @color.set @data().focusColor
    @colorL.set @data().focusColor if event.target.value.length > 0
    if @data().labelFloat == 'false'
      @float.set('label-hidden')
    else
      @float.set('label-floating')
    @colorL.set @data().focusColor


  onFocusOut: (event) ->
    @onInput(event.target)
    @underline.set ''
    @color.set ''
    @colorL.set ''



  onInput: (input) ->
    @charCount.set("#{input.value.length}/#{@data().charMax}")
    if input.value.length <= 0
      @float.set ''
      @colorL.set ''
    else if @data().labelFloat == 'false'
      @float.set('label-hidden')
    else
      @float.set('label-floating')






  events: ->
    super.concat
      'focusin .pinput': @onFocusIn
      'focusout .pinput': @onFocusOut
      # 'input .pinput': @onInput
