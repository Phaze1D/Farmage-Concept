
require './PaperTabPanel.tpl.jade'
require './PaperTab.tpl.jade'

class PaperTabPanel extends BlazeComponent
  @register 'PaperTabPanel'

  constructor: (args) ->


  tabWidth: ->
    100/@data().tabs.length
