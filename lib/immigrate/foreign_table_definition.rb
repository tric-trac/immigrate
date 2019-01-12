module Immigrate
  class ForeignTableDefinition
    NATIVE_DATABASE_TYPES = {
      string:      'character varying',
      text:        'text',
      bigint:      'bigint',
      integer:     'integer',
      float:       'float',
      decimal:     'decimal',
      datetime:    'timestamp',
      time:        'time',
      date:        'date',
      daterange:   'daterange',
      numrange:    'numrange',
      tsrange:     'tsrange',
      tstzrange:   'tstzrange',
      int4range:   'int4range',
      int8range:   'int8range',
      binary:      'bytea',
      boolean:     'boolean',
      xml:         'xml',
      tsvector:    'tsvector',
      hstore:      'hstore',
      inet:        'inet',
      cidr:        'cidr',
      macaddr:     'macaddr',
      uuid:        'uuid',
      json:        'json',
      jsonb:       'jsonb',
      ltree:       'ltree',
      citext:      'citext',
      point:       'point',
      line:        'line',
      lseg:        'lseg',
      box:         'box',
      path:        'path',
      polygon:     'polygon',
      circle:      'circle',
      bit:         'bit',
      bit_varying: 'bit varying',
      money:       'money',
    }

    attr_reader :server, :name, :columns

    def initialize name, server, **options
      options.assert_valid_keys(:schema_name, :table_name, :primary_key)
      @name = name
      @server = server
      @columns = []
      @options = options
    end

    def column name, type
      @columns << [name, type]
    end

    NATIVE_DATABASE_TYPES.keys.each do |column_type|
      module_eval <<-CODE, __FILE__, __LINE__ + 1
        def #{column_type} name
          column name, :#{column_type}
        end
      CODE
    end

    def sql
      "CREATE FOREIGN TABLE #{name} (#{column_definitions}) SERVER #{server} OPTIONS (#{options})"
    end

    def column_definitions
      columns.map { |column| "#{column.first} #{native_column_type column.second}"}.join(',')
    end

    def native_column_type type
      NATIVE_DATABASE_TYPES[type]
    end

    def options
      @options.map { |option| "#{option.first} '#{option.second}'"}.join(',')
    end
  end
end
