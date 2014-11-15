
TODO
----
* Add the license to the tops of all files.  
* Finish adding the structure of the project. 
* Make it a gem so that it can be installed by the build. 
* Compare everything with the Action Mailer gem.  
* Add documentation so that RDoc looks kind of good.  
* Write a high level interface class that adds virtual directories and 
does other stuff. 
* Write a command-line tool that adds IIS and Apache directories.  Have it 
also create quick .htaccess files.  
* Write up this README in RDoc.  
* The start section and end section stuff is a little confusing.  
* Convert '>' and '<' to &gt; and &lt; respectively?  
* Make the line endings cross platform.  There must be some sort of 
environmental variable for it.  
* There is no concept of a parent node.  This should be added with an 
add_node method.  
* The child_nodes.push array is bad.  It can't check if the node isn't itself.  
It needs to prevent itself from being attached to itself.  It causes a nasty
recursive error.  
* In the installer add a link to your home page for news and stuff!

Links
-----
* Apache configuration: http://httpd.apache.org/docs/2.0/configuring.html
* LR parser: http://en.wikipedia.org/wiki/LR_parser

Apache Config Libraries
-----------------------
* Apache-Admin-Config: http://rs.rhapsodyk.net/devel/apache-admin-config/
* Apache-ConfigFile: http://search.cpan.org/~nwiger/Apache-ConfigFile-1.18/ConfigFile.pm
* Config-ApacheFormat: http://search.cpan.org/~samtregar/Config-ApacheFormat-1.2/ApacheFormat.pm

== Running with Rake

The easiest way to run the unit tests is through Rake. The default task runs
the entire test suite for all classes. For more information, checkout the 
full array of rake tasks with "rake -T"

Rake can be found at http://rake.rubyforge.org

== Running by hand

If you only want to run a single test suite, or don't want to bother with Rake,
you can do so with something like:

   ruby controller/base_tests.rb

== Dependency on ActiveRecord and database setup

Test cases in test/controller/active_record_assertions.rb depend on having
activerecord installed and configured in a particular way. See comment in the
test file itself for details. If ActiveRecord is not in 
actionpack/../activerecord directory, these tests are skipped. If activerecord
is installed, but not configured as expected, the tests will fail.

Other tests are runnable from a fresh copy of actionpack without any configuration.

