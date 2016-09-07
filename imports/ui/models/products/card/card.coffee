
require './card.jade'

class ProductCard extends BlazeComponent
  @register 'ProductCard'

  constructor: (args) ->

  onRendered: ->
    super
    yieldChart = $(@find '.canvas')
    options =
      title:
        display: true
        text: 'Sold In Past 5 Days'
        fontColor: 'black'
        fontSize: 14
        fontStyle: 'normal'
      legend:
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

    yieldBar = new Chart(yieldChart,
      {
        type: 'bar'
        data: data
        options: options
      }
    )
