
require './PaperTabPanel.tpl.jade'
require './PaperTab.tpl.jade'

class PaperTabPanel extends BlazeComponent
  @register 'PaperTabPanel'

  constructor: (args) ->

  onRendered: ->
    super
    underline = $(@find('.underline'))
    bar = $(@find('.bar-tab'))
    underline.css width: bar.innerWidth()
    underline.css left: bar.position().left


  tabWidth: ->
    unless @data().scrollable
      100/@data().tabs.length + '%'



  showLine: ->
    @data().tabs.length > 1


  active: (index) ->
    if index is 0
      return "active"

  onBarTabClick: (event) ->
    tar = $(event.currentTarget)
    unless tar.hasClass('active')
      $(@findAll '.bar-tab').removeClass('active')
      tar.addClass('active')
      underline = $(@find '.underline')
      underline.velocity
        p:
          left: tar.position().left + $(@find('.tab-bar')).scrollLeft() + 2
          width: tar.innerWidth()
        o:
          duration: 250
          easing: 'ease-in-out'

      $(@find '.tab-panel-main').velocity
        p:
          translateX: "#{-100 * tar.attr('data-index')}%"
        o:
          duration: 250
          easing: 'ease-in-out'


  events: ->
    super.concat
      "click .js-bar-tab": @onBarTabClick
