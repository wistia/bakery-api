$LOAD_PATH.unshift File.dirname(__FILE__) + '/bakery'

require 'active_resource'
require 'configuration'

require 'resource'
require 'media'
require 'derivative'
require 'signature'
require 'options'

Bakery::Configuration.initialize