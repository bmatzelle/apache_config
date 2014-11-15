
require File.dirname(__FILE__) + '/abstract_unit'

class DocumentTest < Test::Unit::TestCase

  # Tests

  def test_simple_load
    conf_path = 'test_simple_load.conf'
    writer = ApacheConfig::Writer.new(conf_path)

    assert_not_nil writer
    writer.indentation = 2
    writer.write_comment('Test file')
    writer.indentation = 4
    writer.write_directive('ServerRoot', 'c:/temp')
    writer.write_directive('Host', 'localhost')
    writer.close

    doc = ApacheConfig::Document.new
    doc.load(conf_path)
    
    assert_equal '#document', doc.name
    assert_equal ApacheConfig::TYPE_DOCUMENT, doc.type

    assert_equal 3, doc.child_nodes.length

    # Tests the comment    
    node = doc.child_nodes[0]
    assert_equal 2, node.indentation
    assert_equal 'Test file', node.value
    assert_equal ApacheConfig::TYPE_COMMENT, node.type
    assert_nil node.name
    
    assert_equal 1, doc.comments.length
    assert_equal node, doc.comments[0]

    # Tests the directives
    node = doc.child_nodes[1]
    assert_equal 4, node.indentation
    assert_equal 'c:/temp', node.value[0]
    assert_equal ApacheConfig::TYPE_DIRECTIVE, node.type
    assert_equal 'ServerRoot', node.name
    
    assert_equal 2, doc.directives.length
    assert_equal node, doc.directives[0]
    
    node = doc.child_nodes[2]
    assert_equal 4, node.indentation
    assert_equal 'localhost', node.value[0]
    assert_equal ApacheConfig::TYPE_DIRECTIVE, node.type
    assert_equal 'Host', node.name
    
    # Tests selecting the directives
    assert_equal doc.child_nodes[1], doc.directives('ServerRoot')[0]
    assert_equal doc.child_nodes[2], doc.directives('Host')[0]

    assert_equal 0, doc.sections.length
    
    File.delete(conf_path)
  end
  
  def test_nested_sections
    conf_path = 'test_nested_sections.conf'
    writer = ApacheConfig::Writer.new(conf_path)

    assert_not_nil writer
    writer.indentation = 0
    writer.write_start_section('Directory', 'c:/dev/web')
    writer.indentation = 2
    writer.write_directive('AllowOverride', 'FileInfo AuthConfig Limit')
    writer.write_directive('ServerName', 'www.host.com')
    writer.write_start_section('Limit', 'GET POST OPTIONS PROPFIND')
    writer.indentation = 4
    writer.write_directive('Order', 'allow,deny')
    writer.write_directive('Allow', 'from all')
    writer.indentation = 2
    writer.write_end_section
    writer.indentation = 0
    writer.write_end_section
    writer.close

    doc = ApacheConfig::Document.new
    doc.load(conf_path)

    assert_equal 1, doc.sections.length
    directory_section = doc.sections[0]
    assert_equal 'Directory', directory_section.name
    
    assert_equal 2, directory_section.directives.length

    override_node = directory_section.directives[0]
    assert_equal 'AllowOverride', override_node.name
    assert_equal ['FileInfo', 'AuthConfig', 'Limit'], override_node.value
    
    server_node = directory_section.directives[1]
    assert_equal 2, server_node.indentation
    assert_equal 'ServerName', server_node.name
    assert_equal 'www.host.com', server_node.value[0]
    
    limit_section = directory_section.sections('Limit')[0]
    assert_not_nil limit_section
    assert_equal 2, limit_section.indentation
    assert_equal ['GET', 'POST', 'OPTIONS', 'PROPFIND'], limit_section.value
    
    order_node = limit_section.directives('Allow')[0]
    assert_equal 4, order_node.indentation
    assert_equal 'Allow', order_node.name
    assert_equal ['from', 'all'], order_node.value

    File.delete(conf_path)
  end
  
  def test_create_save
    # Create a document here and save it. 
    conf_path = 'test_create_save.conf'
    doc = ApacheConfig::Document.new
    node = ApacheConfig::Node.new
    node.type = ApacheConfig::TYPE_COMMENT
    node.value = 'Test document'
    
    doc.child_nodes.push node
    
    node = ApacheConfig::Node.new
    node.type = ApacheConfig::TYPE_DIRECTIVE
    node.name = 'AllowOverride'
    node.value = ['FileInfo', 'AuthConfig', 'Limit']
    
    doc.child_nodes.push node
    
    section_node = ApacheConfig::Node.new
    section_node.type = ApacheConfig::TYPE_SECTION_START
    section_node.name = 'Limit'
    section_node.value = ['GET', 'POST', 'OPTIONS', 'PROPFIND']
    
    doc.child_nodes.push section_node
    
    node = ApacheConfig::Node.new
    node.type = ApacheConfig::TYPE_DIRECTIVE
    node.name = 'Order'
    node.value = 'allow,deny'
    node.indentation = 2
    
    section_node.child_nodes.push node
    
    doc.save conf_path
    
    # Perform the testing on the new document
    
    doc = ApacheConfig::Document.new
    doc.load(conf_path)
    
    assert_equal 1, doc.comments.length
    assert_equal 'Test document', doc.comments[0].value

    assert_equal 1, doc.sections.length
    limit_section = doc.sections[0]
    assert_equal 'Limit', limit_section.name
    assert_equal ['GET', 'POST', 'OPTIONS', 'PROPFIND'], limit_section.value
    
    override_node = doc.directives[0]
    assert_equal 'AllowOverride', override_node.name
    assert_equal ['FileInfo', 'AuthConfig', 'Limit'], override_node.value
    
    limit_section = doc.sections('Limit')[0]
    assert_not_nil limit_section
    assert_equal 0, limit_section.indentation
    assert_equal ['GET', 'POST', 'OPTIONS', 'PROPFIND'], limit_section.value
    
    assert_equal 1, limit_section.directives.length
    order_node = limit_section.directives('Order')[0]
    assert_equal 2, order_node.indentation
    assert_equal 'Order', order_node.name
    assert_equal 'allow,deny', order_node.value[0]
    
    File.delete(conf_path)
  end
  
  def test_set_save
  	# simple set and save test
  end
  
  def test_append_to_end
    # go to the end of the file and append the following:
    #Listen 81
    #NameVirtualHost *:81
    
    #<VirtualHost *:81>
    #    ServerAdmin webmaster@host.com
    #    DocumentRoot C:/dev/web/BrentBits/public
    #    ServerName www.host.com
    #    Options Indexes ExecCGI FollowSymLinks
    #    AddHandler cgi-script .cgi
    #    AddHandler fastcgi-script .fcgi
    #    RewriteEngine On
    #</VirtualHost>
  end
  
  def test_load_modules
    # This should add the modules to load right underneath the other ones:
    # LoadModule rewrite_module modules/mod_rewrite.so
    # LoadModule fastcgi_module modules/mod_fastcgi.so
  end
  
  def test_turn_on_fastcgi
    # This one will turn on FastCGI and turn off the normal CGI (commenting it)
    # #RewriteRule ^(.*)$ dispatch.cgi [QSA,L]
    # RewriteRule ^(.*)$ dispatch.fcgi [QSA,L]
  end
  
  def test_delete_node
    # Delete a virtual directory node and all children.  
  end
  
  def test_save
    # This one will delete a node, save it and then load it again to see 
    # if the changes stick.  
  end
  
  # Helper methods


end