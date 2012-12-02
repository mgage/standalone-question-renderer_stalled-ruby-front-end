standalone-question-renderer
============================

This isolates the features of webwork which simply render a problem, independent of any connection with a database or with a webserver.

## Required ##

1. This application uses some extra modules from CPAN which may not be available in your local perl installation. 
The script   `bin/check_modules.pl` will tell you 
which ones you are missing (for the full WW installation).  The file `bin/extras` lists the ones I needed to add to get this to work.  YMMV


1. This example uses jsMath to display equations so you may need to have that installed to see the equations typeset.


To use
--------

(1) To see the generator in operation use these commands in the top directory:

 	run_problem_generator.pl 1>tmp.html 2>warnings
 	open tmp.html
 
 
 
A lot of extraneous warnings are created.  I'll try to clean those up soon.


(2) To generate data for input to the question-render

	cd clients
	./renderProblem2.pl input.txt
	ls
you will see

	data_server_to_client.txt	input.txt renderProblem2.pl		renderProblemOutput1.html
	
The `data_server_to_client.txt` file contains the 
code needed for input to the question renderer. Place it in the `data` directory.  The other files there show sample outputs created while building this application.
The `renderProblemOutput1.html` file is produced and fed
to a browser.

Variations
----------

There are several different pretty print output formats
that can be chosen in `RenderProblem.pm`.  

The input and output files are currently hardwired in `renderProblem2.pl` and `RenderProblem.pm`

To Do
--------------

1. Track down the warnings and fix them. Many are warnings from PG macros.

2. Continue to rework the configuration used in defineProblemEnvir  so that it is modular and can be adapted for both this stand alone generator and for a full fledged WeBWorK site.
3. Make it easier to switch output formats and input files.
4. Rename the client `renderProblem2.pl` to something less confusing.
5. Look at the various "2" versions in particular `Local2.pm` and see if its possible to adapt them to use the standard `Local.pm` file -- possibly modifying the latter.
6. Add the ability to handle images mode by adding a small database of some kind.

Project
------------

Put a Ruby webserver front end on this so that the client
send a .pg file, have it rendered and returned to the client which pushes it through a browser.  The problem in the browser is active in the sense that if the submit button is pressed the entered answers are checked and a new version of the question with answers checked is returned to the browser.

You can use `https://hosted2.webwork.rochester.edu/` as a webserver for testing if you don't have a local host installed.



 


 