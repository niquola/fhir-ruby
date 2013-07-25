module Fhir
  module MigrationHelpers
    def identifier_table(entity_name)
      create_table("certification_#{entity_name}_identifiers") do |t|
        t.integer "#{entity_name}_id"
        t.string :use # enum
        t.string :label
        t.string :system_name
        t.string :key
        t.string :assigner_id #references organization
      end
    end

    def coding_fields(t, *path)
      prefix = path.present? ? "#{path.join('__')}__" : ''
      t.string "#{prefix}system_name"
      t.string "#{prefix}code"
      t.string "#{prefix}display"
    end

    def period_fields(t, *path)
      prefix = path.present? ? "#{path.join('__')}__" : ''
      t.string "#{prefix}start_datetime"
      t.string "#{prefix}end_datetime"
    end

    def quantity_fields(t, *path)
      prefix = path.present? ? "#{path.join('__')}__" : ''
      t.decimal "#{prefix}value"
      t.string "#{prefix}comparator" #code
      t.string "#{prefix}units"
      t.string "#{prefix}system_name" #uri
      t.string "#{prefix}code" #code
    end

    def ratio_fields(t, *path)
      quantity_fields t, *(path + [:numerator])
      quantity_fields t, *(path + [:denominator])
    end
  end
end
