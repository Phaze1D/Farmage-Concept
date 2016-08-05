IndexMixin = require '../../../mixins/index_mixin.coffee'

require './index.jade'

class IngredientsIndex extends IndexMixin
  @register 'ingredients.index'

  constructor: (args) ->
    super
