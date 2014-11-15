
require File.dirname(__FILE__) + '/abstract_unit'

class WriterTest < Test::Unit::TestCase

  # Tests

  def test_simple_directive
    conf_path = 'simple_directive.conf'
    writer = ApacheConfig::Writer.new(conf_path)

    assert_not_nil writer
    writer.write_empty
    writer.write_comment(' Test file')
    writer.write_directive('ServerRoot', 'c:/temp')
    assert File.exists?(conf_path)
    writer.close
    
    file = File.open(conf_path, 'r')
    lines = file.readlines
    file.close
    
    assert_line_equal "", lines[0]
    assert_line_equal "# Test file", lines[1]
    assert_line_equal "ServerRoot c:/temp", lines[2]
    
    File.delete(conf_path)
  end
  
  def test_array_directive
    conf_path = 'array_directive.conf'
    writer = ApacheConfig::Writer.new(conf_path)

    assert_not_nil writer
    writer.write_directive('Allow', ['from', 'all'])
    writer.close
    
    file = File.open(conf_path, 'r')
    lines = file.readlines
    file.close
    assert_line_equal 'Allow from all', lines[0]
    
    File.delete(conf_path)
  end
  
  def test_simple_section
    conf_path = 'simple_section.conf'
    writer = ApacheConfig::Writer.new(conf_path)

    writer.write_start_section('Directory')
    writer.write_directive('Test', 'Directive')
    writer.write_end_section
    writer.close
    
    file = File.open(conf_path, 'r')
    lines = file.readlines
    file.close
    
    assert_line_equal '<Directory>', lines[0]
    assert_line_equal 'Test Directive', lines[1]
    assert_line_equal '</Directory>', lines[2]
    
    File.delete(conf_path)
  end
  
  def test_complex_section
    conf_path = 'complex_section.conf'
    writer = ApacheConfig::Writer.new(conf_path)

    assert_not_nil writer
    assert File.exists?(conf_path)

    writer.write_comment(' Test file')
    writer.write_start_section('Directory', '"c:/dev/web"')
    writer.indentation = 2
    writer.write_directive('AllowOverride', 'FileInfo AuthConfig Limit')
    writer.write_start_section('Limit', ['GET', 'POST', 'OPTIONS', 'PROPFIND'])
    writer.indentation = 4
    writer.write_directive('Order', 'allow,deny')
    writer.write_directive('Allow', 'from all')
    writer.indentation = 2
    writer.write_end_section
    writer.indentation = 0
    writer.write_end_section
    writer.close
    
    file = File.open(conf_path, 'r')
    lines = file.readlines
    file.close
    
    assert_line_equal '# Test file', lines[0]
    assert_line_equal '<Directory "c:/dev/web">', lines[1]
    assert_line_equal '  AllowOverride FileInfo AuthConfig Limit', lines[2]
    assert_line_equal '  <Limit GET POST OPTIONS PROPFIND>', lines[3]
    assert_line_equal '    Order allow,deny', lines[4]
    assert_line_equal '    Allow from all', lines[5]
    assert_line_equal '  </Limit>', lines[6]
    assert_line_equal '</Directory>', lines[7]
    
    File.delete(conf_path)
  end
  
  def test_bad_argument_type
    assert_raises ArgumentError do
      writer = ApacheConfig::Writer.new(393)
    end
  end
  
  # Helper methods

  def assert_line_equal(test, line)
    assert_equal(test + "\n", line)
  end

end