# License here

module ApacheConfig

  # Class for writing Apache configuration files
  class Writer
    attr_writer :indentation, :eol

    # Initialize the class.  
    def initialize(file)

      # Figure out the type
      case file
      when IO 
        @file = file
      when String
        @file = File.open(file, 'w')
      else
        raise ArgumentError, 'Expects String or IO argument'
      end

      @indentation = 0
      @eol = "\n"
      #@eol = "\r\n"

      @sections = []
    end
    
    # Cleans up any resources.  
    def close
      @file.close
    end
    
    # Writes a directive to file. 
    # TODO: Make the value an array.  
    def write_directive(name, value)
      write_line(name + ' ' + value_to_s(value))
    end
    
    # Writes a comment to file.
    def write_comment(value)
      write_line('#' + value)
    end
    
    # Writes an empty line
    def write_empty
      write_line('')
    end
    
    # Writes a start section.  
    # TODO: Make the value an array.  
    def write_start_section(name, value = '')
      @sections.push name
      
      value_text = value_to_s(value)
      if value.length > 0
      	write_line("<#{name} #{value_text}>")
      else
      	write_line("<#{name}>")
      end
    end
    
    # Writes the end of a section.  
    def write_end_section()
      name = @sections.pop
      write_line("</#{name}>")
    end
    
    # add a to_s here? 
    
    private
      # Writes a line to the file.  
      def write_line(text)
        write_white_space
        @file.write(text + @eol)
      end
      
      # Writes white space up to the indentation
      def write_white_space
        #@file.write String.new.rjust(@indentation)
        @file.write(' ' * @indentation)
      end
      
      # Converts a value to a string. 
      def value_to_s(value)
        case value
        when String
          result = value
        when Array
          result = value.join(' ')
        end
        
        return result
      end
  end
end