module Simple

  module Printable

    PrintableField = Struct.new('PrintableField', :key, :label, :value)

    def printable
      []
    end

    def make_fields
      @printable_fields = printable.map do |field|
        key = label = value = nil
        case field
        when Symbol
          key = field
        when Array
          field = field.dup
          key = field.shift
          label = field.shift if field.first.kind_of?(String)
          value = field.shift
        when Hash
          key, label, value = field[:key], field[:label], field[:value]
        else
          raise
        end
        label ||= key.to_s.capitalize
        value ||= proc { send(key) }
        PrintableField.new(key, label, value)
      end
      @printable_fields_width = @printable_fields.map { |f| f.label.length }.max
    end

    def print(output: STDOUT, indent: 0)
      make_fields unless @printable_fields
      @printable_fields.each do |field|
        value = field.value.kind_of?(Proc) ? field.value.call(field.key) : field.value
        output.print '%s%*s: ' % [
          ' ' * indent,
          @printable_fields_width,
          field.label,
        ]
        if value.kind_of?(Array)
          output.puts
          value.each { |v| v.print(output: output, indent: indent + 2 + @printable_fields_width) }
        else
          output.puts value
        end
      end
      output.puts
    end

  end

end