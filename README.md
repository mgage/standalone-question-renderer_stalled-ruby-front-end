Project
------------
This was a hackathon project for a computer science class in fall 2012 taught by Prof. Chen Ding. 
A fair amount of progress was made in creating a Ruby front end in one day of hacking but the 
project remains unfinished.  It might be an interesting starting place for someone interested in finishing
the job.  

See also the repo  mgage/standaloneProblemRenderer for a similar idea but with a perl front end. 
It is under more active construction. 

The most active project along this line is the file sendXMLRPC.pl in 
openwebwork/webwork2/clients.  

All of these are designed to cement the API between PG and some front end (e.g. webwork2).


Project description
--------------------

Put a Ruby webserver front end on the PG renderer so that the client
can send a .pg file, have it rendered and 
returned to the client which pushes it through a browser.  

PG is the language used to write mathematics questions for WeBWorK.  It is basically perl with 
additional macros that make it easier to write and to check the answers to mathematics homework
problems.  

A light weight Ruby server installations will make it possible to write and check homework questions
on a laptop without connections to the web.

The question returned to  the browser is active in the sense that 
when it is resubmitted to the PG renderer the entered answers are checked
and the result is  returned to the browser.


The UML for the project is at:  
http://mgage.github.com/standalone-question-renderer/csc253_server_project.html

The items in yellow are the scripts that should be written to connect the Ruby webserver and the 
PG renderer engine.  If XMLRPC is used as a transport mechanism
then the existing perl client can be used to check the operation of the server and the renderer.

The items in blue constitute perl code that duplicates the functionality of renderProblem.pl which
can be used as a model.

A description of the existing perl code for the PG renderer is in README2.


