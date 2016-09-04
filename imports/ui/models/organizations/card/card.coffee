
Chart = require 'chart.js'

require './card.jade'

class OrganizationCard extends BlazeComponent
  @register 'OrganizationCard'

  constructor: (args) ->
    # body...

  onCreated: ->
    super


  onRendered: ->
    super
    Chart.defaults.global.title.display = false;
    Chart.defaults.global.legend.display = false;
    # Chart.defaults.global.tooltips.enabled = false;
    Chart.defaults.global.defaultFontSize = 10
    # ctx = $('.chart-1')
    # $('.chart').each () ->
    #   options =
    #     maintainAspectRatio: false
    #     borderWidth: 0
    #     scales:
    #       xAxes: [
    #               gridLines:
    #                 display: false
    #              ]
    #
    #       yAxes: [
    #               gridLines:
    #                 drawBorder: false
    #               ]
    #
    #   data =
    #     labels: ["08/30", "08/30", "09/01", "09/02", "09/03"],
    #     datasets: [
    #         {
    #           borderColor: "rgba(75,192,192,1)",
    #           data: [65, 59, 80, 81, 56],
    #         }
    #   ]
    #
    #   myLineChart = new Chart(@,
    #     {
    #       type: 'line'
    #       data: data
    #       options: options
    #     }
    #   )


  founder:  ->
    Meteor.users.findOne @data().organization.founder().user_id

  tabs: ->
    ['Sells', 'Expenses']
