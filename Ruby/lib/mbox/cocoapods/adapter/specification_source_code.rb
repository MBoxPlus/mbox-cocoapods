
require 'cocoapods-core/specification'
require 'cocoapods-core/specification/dsl'
require 'cocoapods-core/specification/dsl/attribute_support'

module Pod
  class Specification
    extend Pod::Specification::DSL::AttributeSupport
    root_attribute  :source_code,
                    :container => Hash,
                    :keys      => Pod::Specification::DSL::SOURCE_KEYS,
                    :required  => false

    def source_code
      value = attributes_hash['source_code']
      if value && value.is_a?(Hash)
        Specification.convert_keys_to_symbol(value)
      else
        value
      end
    end
  end
end
