# License here

module ApacheConfig

  # Apache line types
  TYPE_NONE = 0
  TYPE_EMPTY = 1
  TYPE_COMMENT = 2
  TYPE_SECTION_START = 3
  TYPE_SECTION_END = 4
  TYPE_DIRECTIVE = 5
  TYPE_DOCUMENT = 6

  # Forward only, non-caching Apache configuration file parser.  
  class Reader
    attr_reader :indentation, :type, :name, :value, :column, :line

    # Initialize the class.  
    def initialize(file)
      # Figure out the type
      case file
      when IO 
        @file = file
      when String
        @file = File.open(file, 'r')
      else
        raise ArgumentError, 'Expects String or IO argument'
      end

      reset_line

      @column = 0
      @line = 0
    end
    
    # Reads a line of the file.  
    def read
      result = true
      
      reset_line
      @indentation = read_whitespace
      
      ch = peek_char
      
      case ch
      when nil
        result = false
      when "\n"
        @type = TYPE_EMPTY
        read_char # Consume the last "\n" character
      when "#"
        @type = TYPE_COMMENT
        read_comment
      when "<"
        read_section
      else
        @type = TYPE_DIRECTIVE
        read_directive
      end
      
      return result
    end
    
    # Cleans up all resources. 
    def close
      @file.close
    end
    
    private
    
      # Reads the comment text into the value
      def read_comment
        @value = ''
        read_char # Remove leading "#"
        while true
          ch = read_char
          break if is_eol(ch)
          @value += ch
        end

        @value = @value.chomp # Remove "\r"
      end
      
      # Reads a directive
      def read_directive
        @name = read_name
        
        read_values
        
        # todo: Should this be here?
        read_char # Consume '\n'
      end
      
      # Reads a directive value.  Returns nil if there aren't any values. 
      def read_values
        @value = []
        
        # Loop through all values
        while true
          read_whitespace # Remove all whitespace in between values
          read_value
          
          ch = peek_char
          break if is_eol(ch) # stop at end of line
          
          if ch == '>' && @type == TYPE_SECTION_START
            read_char # Consume '>'
            return
          end
        end
      end
      
      # Reads a section. 
      def read_section
      	read_char # Consume '<'
      	
      	if peek_char == '/' then
      	  @type = TYPE_SECTION_END
      	  read_char # Consume '/'
      	  @name = read_name
      	else
      	  @type = TYPE_SECTION_START
      	  @name = read_name
      	  
      	  read_whitespace
      	  if peek_char == '>'
      	    read_char # Consume '>'
      	    read_whitespace # Go to the end of the line
      	  else
      	    # There should be a value to consume
      	    read_values
      	  end
      	end
      	
      	read_char # Consume '\n'
      end
      
      # Reads and returns the name.  
      def read_name
      	result = ''
      	
      	is_section = (@type == TYPE_SECTION_START || @type == TYPE_SECTION_END)

      	while true
      	  break if is_section && (peek_char() == '>')

          ch = read_char
          break if is_eol(ch) || is_whitespace(ch)
          
          result += ch
        end
        
        return result
      end
      
      # Reads a directive or section value.  
      def read_value
          index = 0
          ch = peek_char

          if is_eol(ch): return end # Exit

          if ch == '"' then
            # start quoted value
            read_char # consume '#'
            quoted = true
          end
          
          new_value = ''
          # Consume all characters.  
          while true
            ch = read_char

            # if "\\" and ends with \r\n then continue on next line
            
            if quoted then
              if ch == "\\" then
                if peek_char == '"': ch = read_char end
              else
                break if ch == '"' # drop '"' character
              end
            else
              # Spaces are a new value if not quoted
              break if is_whitespace(ch) || (@type == TYPE_SECTION_START && ch == '>')
            end
            
            new_value += ch
            
            break if is_eol(peek_char)
          end
          
          @value.push new_value.chomp
      end

      # Reads through all white space before the end of the line. 
      def read_whitespace
        result = 0
        
        while true
          ch = peek_char
          break if !is_whitespace(ch) || is_eol(ch)
          
          ch = read_char # Consume space ' '
          result += 1
        end
        
        return result
      end
      
      # Returns true if it is white space.  
      def is_whitespace(text)
        return text == ' ' || text == "\r" || text == "\n"
      end
      
      # Returns true if it is the end of a line.  
      def is_eol(text)
        return text == "\n" || text == nil
      end
      
      # Returns a character without consuming it.  
      def peek_char
        @peek = @file.read(1)
        
        # Do not move back if end of file
        if @peek != nil then
          # Return back to the previous character
          @file.seek(-1, IO::SEEK_CUR)
        end

        return @peek
      end
      
      # Returns and consumes the next character. 
      def read_char
        ch = @file.read(1)
        
        if ch == "\n"
          @line += 1
          @column = 0
        else
          @column += 1
        end

        return ch
      end

      # Resets the line statistics.        
      def reset_line
        @indentation = 0
        @name = nil
        @type = TYPE_EMPTY
        @value = nil
      end
    
  end
end