# 
# Extension to handle Activy Stream Location element
#
module Atom
   module Extensions
    class Location 
      include Atom::Xml::Parseable

      namespace "http://activitystrea.ms/spec/1.0/"
      element :displayName, :position

      def initialize(name = nil, value = nil)
        if name && value
          initialize_with_o :name => name, :value => value
        else
          initialize_with_o(name) { yield if block_given? }
        end
      end

      def initialize_with_o(o = nil)
        case o
        when XML::Reader
          o.read
          parse o
        when Hash
          o.each do |name,value|
            self.send("#{name.to_s}=", value)
          end
        else
          out.print "Exception in Location\n"
          yield(self) if block_given?
        end
      end

      def inspect
        "<Atom::Location displayName:'#{displayName}' position:'#{position}'"
      end
    end  
  end
end
