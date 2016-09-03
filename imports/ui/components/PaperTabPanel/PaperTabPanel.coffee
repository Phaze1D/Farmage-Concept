
require './PaperTabPanel.tpl.jade'
require './PaperTab.tpl.jade'

class PaperTabPanel extends BlazeComponent
  @register 'PaperTabPanel'

  constructor: (args) ->


  tabWidth: ->
    100/@data().tabs.length


  active: (index) ->
    if index is 0
      return "active"

  onBarTabClick: (event) ->
    tar = $(event.currentTarget)
    unless tar.hasClass('active')
      $(@findAll '.bar-tab').removeClass('active')
      tar.addClass('active')
      $(@find '.underline').velocity
        p:
          translateX: "#{100 * tar.attr('data-index')}%"
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
