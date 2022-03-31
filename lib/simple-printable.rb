module Simple

  module Printable

    Field = Struct.new('Field', :key, :label, :value)

    def printable
      []
    end

    def make_fields
      @printable_fields = printable.map do |field|
        key = label = value = nil
        case field
        when Field
          next field
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
          raise "Unknown field specification: #{field.inspect}"
        end
        label ||= key.to_s.capitalize
        value ||= proc { send(key) }
        Field.new(key, label, value)
      end
      @printable_fields_width = @printable_fields.map { |f| f.label.length }.max
    end

    def print(output: STDOUT, indent: 0)
      output ||= StringIO.new
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
          value.each_with_index do |o, i|
            output.puts if i > 0
            o.print(output: output, indent: indent + 2 + @printable_fields_width)
          end
        else
          output.puts value
        end
      end
      if output.kind_of?(StringIO)
        output.rewind
        output.read
      else
        nil
      end
    end

  end

end