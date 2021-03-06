require 'active_record/connection_adapters/abstract_adapter'
require 'active_support/core_ext/kernel/requires'
require 'active_support/core_ext/hash'
require 'uuidtools'

require 'active_record/connection_adapters/simpledb_adapter/misc/aws_overrides'
require 'active_record/connection_adapters/simpledb_adapter/misc/simpledb_logger'
require 'active_record/connection_adapters/simpledb_adapter/finder_methods'
require 'active_record/connection_adapters/simpledb_adapter/base'
require 'active_record/connection_adapters/simpledb_adapter/validations'
require 'active_record/connection_adapters/simpledb_adapter/table_definition'
require 'active_record/connection_adapters/simpledb_adapter/column'
require 'active_record/connection_adapters/simpledb_adapter/adapter'
require 'active_record/connection_adapters/simpledb_adapter/defaults'

ActiveRecord::Base.send :include, ActiveRecordSimpledbAdapter::Defaults
