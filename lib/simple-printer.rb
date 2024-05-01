require 'stringio'

module Simple

  class Printer

    def self.print(*fields, **params)
      new(fields).print(**params)
    end

    def initialize(fields)
      @fields = fields.map { |s| Field.make(spec: s) }
    end

    def print(output: STDOUT, indent: 0)
      output ||= StringIO.new
      max_label_width = @fields.map { |f| f.label.length }.max
      @fields.each do |field|
        output.puts '%s%*s:%s' % [
          ' ' * indent,
          max_label_width,
          field.label,
          field.value.nil? ? '' : " #{field.value}",
        ]
        if field.children
          field.children.each_with_index do |o, i|
            output.puts if i > 0
            o.print(output: output, indent: indent + 2 + max_label_width)
          end
        end
      end
      if output.kind_of?(StringIO)
        output.rewind
        output.read
      else
        nil
      end
    end

    class Field

      attr_accessor :key
      attr_accessor :label
      attr_accessor :value
      attr_accessor :children

      def self.make(spec:, object: nil)
        return spec if spec.kind_of?(Field)
        Field.new.tap do |field|
          case spec
          when Symbol
            field.key = spec
          when Array
            spec = spec.dup
            field.key = spec.shift if spec.first.kind_of?(Symbol)
            field.label = spec.shift if spec.first.kind_of?(String)
            case (v = spec.shift)
            when Array
              field.children = v
            else
              field.value = v
            end
          when Hash
            field.key, field.label, field.value, field.children = spec[:key], spec[:label], spec[:value], spec[:children]
          else
            raise "Unknown field specification: #{spec.inspect}"
          end
          if field.key
            field.label ||= field.key.to_s.tr('_', ' ').capitalize
            if field.value.nil?
              raise "No object specified" unless object
              v = object.send(field.key)
              if v.kind_of?(Array)
                field.children = v
              else
                field.value = v
              end
            end
          end
        end
      end

      def initialize(params={})
        params.each { |k, v| send("#{k}=", v) }
      end

    end

    module Printable

      def printable
        []
      end

      def print(**params)
        Printer.new(printable.map { |s| Field.make(spec: s, object: self) }).print(**params)
      end

    end

  end

end