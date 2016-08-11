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
    @data().size = "size-small" unless @data().size?
    @data().labelFloat = true unless @data().labelFloat?
  


  onRendered: ->
    $(@find('.pinput')).trigger('input')
    $(@find('.pinput')).trigger('focusout')
    $(@find('textarea')).textareaAutoSize();
    @onInput @find('.pinput')


  onFocusIn: (event) ->
    @underline.set('highlight')
    @color.set @data().focusColor
    @colorL.set @data().focusColor if event.target.value.length > 0
    if !@data().labelFloat
      @float.set('label-hidden')
    else
      @float.set('label-floating')
      if @data().prefix?
        $(@find '.input-label').css left: "-#{$(@find('.prefix')).outerWidth() + 1}px"
    @colorL.set @data().focusColor


  onFocusOut: (event) ->
    @onInput(event.target)
    @underline.set ''
    @color.set ''
    @colorL.set ''




  onInput: (input) ->

    if input.value.length <= 0
      @float.set ''
      @colorL.set ''
      $(@find '.input-label').css left: '0px'
    else if !@data().labelFloat
      @float.set('label-hidden')
    else
      @float.set('label-floating')
      if @data().prefix?
        $(@find '.input-label').css left: "-#{$(@find('.prefix')).outerWidth() + 1}px"

  onCharInput: (event) ->
    if @data().showCount
      input = @find('.pinput')
      @charCount.set("#{input.value.length}/#{@data().charMax}")







  events: ->
    super.concat
      'focusin .pinput': @onFocusIn
      'focusout .pinput': @onFocusOut
      'input .pinput': @onCharInput
