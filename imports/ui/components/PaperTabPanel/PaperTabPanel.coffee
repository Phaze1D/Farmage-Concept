
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
      pre = $(@find '.bar-tab.active')
      pre.removeClass('active')
      $(@find ".single-tab-main[data-index='#{pre.attr('data-index')}']").removeClass('active-panel')
      tar.addClass('active')
      underline = $(@find '.underline')
      underline.velocity
        p:
          left: tar.position().left + $(@find('.tab-bar')).scrollLeft() + 2
          width: tar.innerWidth()
        o:
          duration: 250
          easing: 'ease-in-out'

      index = tar.attr('data-index')
      $(@find ".single-tab-main[data-index='#{index}']").addClass('active-panel')
      $(@find '.tab-panel-main').velocity
        p:
          translateX: "#{-100 * index}%"
        o:
          duration: 250
          easing: 'ease-in-out'


  events: ->
    super.concat
      "click .js-bar-tab": @onBarTabClick
