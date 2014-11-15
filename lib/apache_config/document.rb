# License here

module ApacheConfig

  # Class for reading and writing to Apache configuration files.  
  # The entire file is loaded into memory.  Indentation is preserved.  
  class Document < ApacheConfig::Node
  
    # Initializes the class.  
    def initialize(path = nil)
      super
      @name = '#document'
      @type = TYPE_DOCUMENT
      @reader = nil
      @path = path
    end

    # Loads a configuration file.  
    def load(file)
      if file == String # does this work?
        @path = file
      end

      @reader = Reader.new(file)
      load_section self, @reader
      @reader.close
    end
    
    # Saves a configuration file.  
    def save(file = nil)
    
      # save to String, IO, or to a path
      case file
        when nil
          if @path == nil
            # throw exception here because there is nothing to save to
          else
            
          end
        when String
          @path = file
      end
      
      writer = Writer.new(@path)
      save_section self, writer
      writer.close
    end
    
    private
      # Possibly load the nodes recursively here
      def load_section(node, reader)

        while @reader.read

       	  new_node = Node.new
      	  new_node.type = @reader.type
      	  new_node.indentation = @reader.indentation
      	  new_node.name = @reader.name
      	  new_node.value = @reader.value
      	  
      	  #puts "New node name: #{new_node.name}"

          if new_node.type == TYPE_SECTION_START
            #puts "Recursing with #{new_node.name}..."
            # Recursively load all sections
            load_section new_node, @reader
          end
          
          if new_node.type == TYPE_SECTION_END
            if node.name != new_node.name
              raise StandardError, "End node (#{new_node.name}) != start node (#{node.name})"
            end

            break # Must break at end of section
          end
      	
          #puts "Adding #{new_node.name} to #{node.name}"
          node.child_nodes.push new_node
        end
      end
      
      # Recursively saves nodes to the writer.  
      def save_section(node, writer)

        node.child_nodes.each do |child|
          writer.indentation = child.indentation
          
          case child.type
          when TYPE_COMMENT
            writer.write_comment child.value
          when TYPE_EMPTY
            writer.write_empty
          when TYPE_SECTION_START
            writer.write_start_section child.name, child.value
            save_section child, writer
            # Force indentation to match the parent
            writer.indentation = child.indentation
            writer.write_end_section
          when TYPE_DIRECTIVE
            writer.write_directive child.name, child.value
          end
        end
      end
  end
  
end