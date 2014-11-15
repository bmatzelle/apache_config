
$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'apache_config'

def type_to_s(type)
  result = ''

  case type
    when ApacheConfig::TYPE_NONE: result = 'none'
    when ApacheConfig::TYPE_EMPTY: result = 'empty'
    when ApacheConfig::TYPE_COMMENT: result = 'comment'
    when ApacheConfig::TYPE_SECTION_START: result = 'section start'
    when ApacheConfig::TYPE_SECTION_END: result = 'section end'
    when ApacheConfig::TYPE_DIRECTIVE: result = 'directive'
  end

  return result
end

path = (ARGV.length > 0) ? ARGV[0] : 'httpd.conf'

reader = ApacheConfig::Reader.new(path)

puts "Starting read..."

i = 0
while reader.read
  puts "Test #{i}:"
  puts '  Type: ' + type_to_s(reader.type)
  
  if reader.name != nil: puts "  Name: #{reader.name}" end
  
  if reader.value != nil
    case reader.value
      when String
        puts "  Value: " + reader.value
      when Array
        value_index = 0
        reader.value.each do |value|
          puts "  Value [#{value_index}]: " + value
          value_index += 1
        end
    end
  end
  
  i += 1
end

