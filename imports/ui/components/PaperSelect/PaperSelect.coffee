require './PaperSelect.tpl.jade'



class PaperSelect extends BlazeComponent
  @register 'PaperSelect'

  constructor: (args) ->
    # body...


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
