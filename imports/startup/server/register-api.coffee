#
require '../../api/collections/users/users.coffee'

# Server Side Logic
require './startup_code.coffee'


# Methods
require '../../api/collections/organizations/methods.coffee'
require '../../api/collections/users/methods.coffee'
require '../../api/collections/customers/methods.coffee'
require '../../api/collections/providers/methods.coffee'
require '../../api/collections/receipts/methods.coffee'
require '../../api/collections/units/methods.coffee'
require '../../api/collections/products/methods.coffee'
require '../../api/collections/yields/methods.coffee'
require '../../api/collections/expenses/methods.coffee'

# Publications
require '../../api/collections/users/server/publications.coffee'
require '../../api/collections/organizations/server/publications.coffee'
require '../../api/collections/customers/server/publications.coffee'
require '../../api/collections/providers/server/publications.coffee'
require '../../api/collections/receipts/server/publications.coffee'
require '../../api/collections/units/server/publications.coffee'
require '../../api/collections/products/server/publications.coffee'
require '../../api/collections/yields/server/publications.coffee'
require '../../api/collections/expenses/server/publications.coffee'
