
require File.dirname(__FILE__) + '/abstract_unit'

class ReaderTest < Test::Unit::TestCase

  # Tests

  def test_simple_read
    conf_path = 'simple_read.conf'
    writer = ApacheConfig::Writer.new(conf_path)

    assert_not_nil writer
    writer.indentation = 2
    writer.write_comment('Test file')
    writer.indentation = 4
    writer.write_directive('ServerRoot', 'c:/temp')
    assert File.exists?(conf_path)
    writer.close
    
    reader = ApacheConfig::Reader.new(conf_path)
    
    assert reader.read
    assert_equal 2, reader.indentation
    assert_equal ApacheConfig::TYPE_COMMENT, reader.type
    assert_nil reader.name
    assert_equal 'Test file', reader.value
    assert_equal 1, reader.line
    
    assert reader.read
    assert_equal 4, reader.indentation
    assert_equal ApacheConfig::TYPE_DIRECTIVE, reader.type
    assert_equal 'ServerRoot', reader.name
    assert_equal 'c:/temp', reader.value[0]
    assert_equal 2, reader.line
    
    assert !reader.read # end of file
    
    reader.close
    
    File.delete(conf_path)
  end
  
  def test_complex_directive
    conf_path = 'complex_directive_read.conf'
    writer = ApacheConfig::Writer.new(conf_path)

    writer.indentation = 6
    writer.write_directive('ServerRoot', ['"c:\\Program Files\\Apache"', 'dos'])
    writer.write_directive('Name', 'dos   unix  ')
    writer.write_directive('Long', ['1', '2', '3', '4', '5'])
    writer.close
    
    reader = ApacheConfig::Reader.new(conf_path)
    assert reader.read
    assert_equal 6, reader.indentation
    assert_equal ApacheConfig::TYPE_DIRECTIVE, reader.type
    assert_equal 'ServerRoot', reader.name
    assert_equal 'c:\Program Files\Apache', reader.value[0]
    assert_equal 'dos', reader.value[1]
    assert_equal 1, reader.line
    
    assert reader.read
    assert_equal ApacheConfig::TYPE_DIRECTIVE, reader.type
    assert_equal 'Name', reader.name
    assert_equal 'dos', reader.value[0]
    assert_equal 'unix', reader.value[1]
    
    assert reader.read
    assert_equal ApacheConfig::TYPE_DIRECTIVE, reader.type
    assert_equal 'Long', reader.name
    assert_equal 5, reader.value.length
    assert_equal '1', reader.value[0]
    assert_equal '2', reader.value[1]
    assert_equal '3', reader.value[2]
    assert_equal '4', reader.value[3]
    assert_equal '5', reader.value[4]

    reader.close
    
    File.delete(conf_path)
  end
  
  def test_directive_quote
    conf_path = 'complex_directive_quote.conf'
    writer = ApacheConfig::Writer.new(conf_path)

    writer.indentation = 6
    writer.write_directive('ServerRoot', '"He said \"hello\" to me"')
    writer.close
    
    reader = ApacheConfig::Reader.new(conf_path)
    assert reader.read
    assert_equal 6, reader.indentation
    assert_equal ApacheConfig::TYPE_DIRECTIVE, reader.type
    assert_equal 'ServerRoot', reader.name
    assert_equal 'He said "hello" to me', reader.value[0]
    assert_equal 1, reader.line

    reader.close
    
    File.delete(conf_path)
  end
  
  def test_section_start_values
  	conf_path = 'section_start_values_read.conf'
    writer = ApacheConfig::Writer.new(conf_path)

    writer.indentation = 2
    writer.write_start_section('Limit', ['"GET ME"', 'POST', '"READ"'])
    writer.close
    
    reader = ApacheConfig::Reader.new(conf_path)
    assert reader.read
    assert_equal 2, reader.indentation
    assert_equal ApacheConfig::TYPE_SECTION_START, reader.type
    assert_equal 'Limit', reader.name
    assert_equal 'GET ME', reader.value[0]
    assert_equal 'POST', reader.value[1]
    assert_equal 'READ', reader.value[2]
    #assert_equal 1, reader.line # TODO: FAILS!

    reader.close
    
    File.delete(conf_path)
  end
  
  def test_section_normal
  	conf_path = 'test_section_normal.conf'
    writer = ApacheConfig::Writer.new(conf_path)

    writer.indentation = 2
    writer.write_start_section('Limit', ['GET', 'POST', 'READ'])
    writer.close
    
    reader = ApacheConfig::Reader.new(conf_path)
    assert reader.read
    assert_equal 2, reader.indentation
    assert_equal ApacheConfig::TYPE_SECTION_START, reader.type
    assert_equal 'Limit', reader.name
    assert_equal 'GET', reader.value[0]
    assert_equal 'POST', reader.value[1]
    assert_equal 'READ', reader.value[2]
    #assert_equal 1, reader.line # TODO: FAILS!

    reader.close
    
    File.delete(conf_path)
  end
  
  def test_simple_section_start
   	conf_path = 'test_simple_section_start.conf'
    writer = ApacheConfig::Writer.new(conf_path)

    writer.write_start_section('VirtualHost')
    writer.write_directive('RootPath', '/www')
    writer.write_end_section
    writer.close
    
    reader = ApacheConfig::Reader.new(conf_path)
    assert reader.read
    assert_equal ApacheConfig::TYPE_SECTION_START, reader.type
    assert_equal 'VirtualHost', reader.name
    assert_nil reader.value
    
    assert reader.read
    assert_equal ApacheConfig::TYPE_DIRECTIVE, reader.type
    assert_equal 'RootPath', reader.name
    
    assert reader.read
    assert_equal ApacheConfig::TYPE_SECTION_END, reader.type
    assert_equal 'VirtualHost', reader.name
    assert_nil reader.value
    
    #assert !reader.read

    reader.close
    
    File.delete(conf_path)
  end
  
  def test_bad_section
    # add characters after '>'
  end
  
  def test_end_in_middle
    # the '>' character in PO>ST
    #assert_raises StandardError do
      conf_path = 'end_in_middle.conf'
      writer = ApacheConfig::Writer.new(conf_path)
  
      writer.indentation = 2
      writer.write_start_section('Limit', ['"GET ME"', 'POST', '"READ"'])
      writer.close
      
      reader = ApacheConfig::Reader.new(conf_path)
      assert reader.read
      
      reader.close
      
      File.delete(conf_path)
    #end
  end
  
  # Helper methods


end