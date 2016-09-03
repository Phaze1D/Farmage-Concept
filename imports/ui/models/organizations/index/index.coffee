
IndexMixin = require '../../../mixins/index_mixin.coffee'
OrganizationModule = require '../../../../api/collections/organizations/organizations.coffee'
Chart = require 'chart.js'

require './index.jade'

class OrganizationsIndex extends IndexMixin
  @register 'organizations.index'

  constructor: (args) ->
    super

  onRendered: ->
    super
    Chart.defaults.global.title.display = false;
    Chart.defaults.global.legend.display = false;
    # Chart.defaults.global.tooltips.enabled = false;
    Chart.defaults.global.defaultFontSize = 10
    ctx = $('.chart-1')

    Meteor.setTimeout( =>
      $('.chart').each () ->
        options =
          maintainAspectRatio: false
          borderWidth: 0
          scales:
            xAxes: [
                    gridLines:
                      display: false
                   ]

            yAxes: [
                    gridLines:
                      drawBorder: false
                    ]

        data =
          labels: ["08/30", "08/30", "09/01", "09/02", "09/03"],
          datasets: [
              {
                borderColor: "rgba(75,192,192,1)",
                data: [65, 59, 80, 81, 56],
              }
        ]

        myLineChart = new Chart(@,
          {
            type: 'line'
            data: data
            options: options
          }
        )

    , 2000)




  organizations: ->
    OrganizationModule.Organizations.find()

  founder: (organization) ->
    Meteor.users.findOne organization.founder().user_id

  tabs: ->
    ['Sells', 'Expenses']
