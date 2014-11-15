# License here

module ApacheConfig

  # Represents an Apache configuration node.  
  class Node
    attr_writer :indentation, :type, :name, :value
    attr_reader :indentation, :type, :name, :value
    
    # Initializes the class.  
    def initialize(type = TYPE_EMPTY, name = nil, value = nil, indentation = 0)
      @type = type
      @name = name
      @value = value
      @indentation = indentation

      @nodes = []
    end
    
    # Returns the entire list of child nodes including comments. 
    def child_nodes
      return @nodes
    end
    
    # Returns a directive by name or all sections if supplied nil.  
    def directives(name = nil)
      return node_list(TYPE_DIRECTIVE, name)
    end
    
    # Returns a section by name or all sections if supplied nil.  
    def sections(name = nil)
      return node_list(TYPE_SECTION_START, name)
    end
    
    # Returns a list of all comments under this node.
    def comments
      return node_list(TYPE_COMMENT, nil)
    end
    
    private
      # Returns an array of all nodes of the supplied type
      def node_list(type, name = nil)
        result = []

        @nodes.each do |node|
          if node.type == type
          	if name == nil
              result.push node
            else
              if name == node.name: result.push node end
            end
          end
        end
        
        return result
      end
  end
  
end