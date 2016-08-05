IndexMixin = require '../../../mixins/index_mixin.coffee'

require './index.jade'

class OUsersIndex extends IndexMixin
  @register 'ousers.index'

  constructor: (args) ->
