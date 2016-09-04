
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
    sellsChart = $(@find '.sells-chart')
    expensesChart = $(@find '.expenses-chart')
    options =
      legend:
        display: false
      title:
        display: false
      maintainAspectRatio: false
      scales:
        xAxes: [
                ticks:
                  fontSize: 10
                gridLines:
                  display: false
               ]

        yAxes: [
                ticks:
                  fontSize: 10
                gridLines:
                  drawBorder: false
                ]

    data =
      labels: ["Nov 30", "Nov 31", "Sep 01", "Sep 02", "Sep 03"]
      datasets: [
                  data: [65, 59, 80, 81, 56]
                ]

    sellsLine = new Chart(sellsChart,
      {
        type: 'line'
        data: data
        options: options
      }
    )

    expensesLine = new Chart(expensesChart,
      {
        type: 'line'
        data: data
        options: options
      }
    )


  founder:  ->
    Meteor.users.findOne @data().organization.founder().user_id

  tabs: ->
    ['Sells', 'Expenses']
