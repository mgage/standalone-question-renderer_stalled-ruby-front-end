#!/usr/local/bin/perl -w 

################################################################################
# WeBWorK Online Homework Delivery System
# Copyright © 2000-2007 The WeBWorK Project, http://openwebwork.sf.net/
# $CVSHeader: webwork2/lib/WebworkWebservice/RenderProblem.pm,v 1.11 2010/06/08 11:22:43 gage Exp $
# 
# This program is free software; you can redistribute it and/or modify it under
# the terms of either: (a) the GNU General Public License as published by the
# Free Software Foundation; either version 2, or (at your option) any later
# version, or (b) the "Artistic License" which comes with this package.
# 
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See either the GNU General Public License or the
# Artistic License for more details.
################################################################################

BEGIN { 
	$main::VERSION = "2.5.2AAA"; 
}

# VERSION created for stand alone project


package RenderProblem;

use lib "/Users/mgage1/webwork/cs253_webwork_project2";
use lib "/Users/mgage1/webwork/cs253_webwork_project2/pg/lib";
use lib "/Users/mgage1/webwork/cs253_webwork_project2/webwork2/lib";

use strict;
use sigtrap;
use Carp;
use WWSafe;

use WeBWorK::CourseEnvironment;
use WeBWorK::PG;
use WeBWorK::PG::Translator;
use WeBWorK::PG::Local2;
use WeBWorK::Utils qw(runtime_use formatDateTime makeTempDirectory);

use WeBWorK::PG::IO;
use WeBWorK::PG::ImageGenerator;
use MIME::Base64 qw( encode_base64 decode_base64);

#print "rereading Webwork\n";


my $debugXmlCode=0;  # turns on the filter for debugging XMLRPC and SOAP code
local(*DEBUGCODE);


our $WW_DIRECTORY = "foobar";
our $PG_DIRECTORY = "./pg";
our $COURSENAME   = "course1";
our $PROTOCOL     = "http";
our $HOST_NAME    = "localhost";
our $PORT         = 80;
our $HOSTURL      = "$PROTOCOL://$HOST_NAME:$PORT"; 




our $UNIT_TESTS_ON =0;

use constant DISPLAY_MODES => {
	# display name   # mode name
	tex           => "TeX",
	plainText     => "HTML",
	formattedText => "HTML_tth",
	images        => "HTML_dpng",
	jsMath	      => "HTML_jsMath",
	MathJax	      => "HTML_MathJax",
	asciimath     => "HTML_asciimath",
};

use constant DISPLAY_MODE_FAILOVER => {
		TeX            => [],
		HTML           => [],
		HTML_tth       => [ "HTML", ],
		HTML_dpng      => [ "HTML_tth", "HTML", ],
		HTML_jsMath    => [ "HTML_dpng", "HTML_tth", "HTML", ],
		HTML_MathJax    => [ "HTML_dpng", "HTML_tth", "HTML", ],
		HTML_asciimath => [ "HTML_dpng", "HTML_tth", "HTML", ],
		# legacy modes -- these are not supported, but some problems might try to
		# set the display mode to one of these values manually and some macros may
		# provide rendered versions for these modes but not the one we want.
		Latex2HTML  => [ "TeX", "HTML", ],
		HTML_img    => [ "HTML_dpng", "HTML_tth", "HTML", ],
};
	






sub renderProblem {
    my $rh = shift;

###########################################
# Grab the course name, if this request is going to depend on 
# some course other than the default course
###########################################
# 	my $courseName;
# 	my $ce;
# 	my $db;
# 	my $user;

#     if (defined($self->{courseName}) and $self->{courseName} ) {
#  		$courseName = $self->{courseName};
#  	} 
#  	
#     # It's better not to get the course in too many places. :-)
#     # High level information about the course should come from $self
#     # Lower level information should come from $rh (i.e. passed by $in at WebworkWebservice)
#     
# 	#FIXME  put in check to make sure the course exists.
# 	eval {
# 		$ce           = WeBWorK::CourseEnvironment->new({webwork_dir=>$WW_DIRECTORY, courseName=> $courseName});
# 		$ce->{apache_root_url}= $HOSTURL;
# 	# Create database object for this course
# 		$db = WeBWorK::DB->new($ce->{dbLayout});
# 	};
# 	# $ce->{pg}->{options}->{catchWarnings}=1;  #FIXME warnings aren't automatically caught 
# 	# when using xmlrpc -- turn this on in the daemon2_course.
# 	#^FIXME  need better way of determining whether the course actually exists.
# 	
# 	# The UNIT_TEST_ON snippets are the closest thing we have to a real unit test.
# 	#
# 	warn "Unable to create course $courseName. Error: $@" if $@;
# 	# my $user = $rh->{user};
# 	# 	$user    = 'practice1' unless defined $user and $user =~/\S/;
# 
# 	my $user = $self->{user_id};
	
###########################################
# Authenticate this request -- done by initiate  in WebworkWebservice 
###########################################



###########################################
# Determine the authorization level (permissions)  -- done by initiate  in WebworkWebservice 
###########################################

###############################################################################
# set up warning handler
###############################################################################
	my $warning_messages="";

	my  $warning_handler = sub {
			my ($warning) = @_;
			CORE::warn $warning;
			chomp $warning;
			$warning_messages .="$warning\n";			
		};

    local $SIG{__WARN__} = $warning_handler;




	# initialize problem source
	my $problem_source;
	my $problemRecord = {};
	my $r_problem_source =undef;
 # 	if (defined($rh->{source})) {
  		$problem_source = decode_base64($rh->{source});
  		$problem_source =~ tr /\r/\n/;
		$r_problem_source =\$problem_source;
#		$problemRecord->source_file($rh->{envir}->{fileName}) if defined $rh->{envir}->{fileName};
#  	} elsif (defined($rh->{sourceFilePath}) and $rh->{sourceFilePath} =/\S/)  {
#  	    $problemRecord->source_file($rh->{sourceFilePath});
#  	}
#	$problemRecord->source_file('foobar') unless defined($problemRecord->source_file);
# 	if ($UNIT_TESTS_ON){
# 			print STDERR "RenderProblem.pm: source file is ", $problemRecord->source_file,"\n";
# 			print STDERR "RenderProblem.pm: problem source is included in the request \n" if defined($rh->{source});
# 	}
    #warn "problem Record is $problemRecord";
	# now we're sure we have valid UserSet and UserProblem objects
	# yay!

##################################################
# Other initializations
##################################################
	my $translationOptions = {
		displayMode     => $rh->{envir}->{displayMode},
		showHints	    => $rh->{envir}->{showHints},
		showSolutions   => $rh->{envir}->{showSolutions},
 		refreshMath2img => $rh->{envir}->{showHints} || $rh->{envir}->{showSolutions},
 		processAnswers  => 1,
 		catchWarnings   => 1,
        # methods for supplying the source, 
        r_source        => $r_problem_source, # reference to a source file string.
        # if reference is not defined then the path is obtained 
        # from the problem object.
        permissionLevel => $rh->{envir}->{permissionLevel} || 0,
	};
	
	my $formFields = $rh->{envir}->{inputs_ref};
	my $key        = $rh->{envir}->{key} || '';
	
	


# We'll try to use this code instead so that Local does all of the work.
# Most of the configuration will take place in the fake course associated
# with XMLRPC responses
#   problem needs to be loaded with the following:
#   	source_file
#       status
#       num_correct
#       num_incorrect
#   it doesn't seem that $effectiveUser, $set or $key is used in the subroutine
#   except that it is passed on to defineProblemEnvironment
	my $effectiveUser;
	my $setRecord = {psvn => 12345};
    my $ce = $WWRenderer::SeedCE;
	my $pg;
	$pg = new(       # call this as a function not as a method.
		$ce,
		$effectiveUser,
		$key,
		$setRecord,
		$problemRecord,
		$setRecord->{psvn}, # FIXME: this field should be removed
		$formFields,
		$translationOptions,
 		{ # extras
# 				overrides       => $rh->{overrides}},
         rh => $rh
         }		
	);
  
    my ($internal_debug_messages, $pgwarning_messages, $pgdebug_messages);
    if (ref ($pg->{pgcore}) ) {
    	$internal_debug_messages = $pg->{pgcore}->get_internal_debug_messages;
    	$pgwarning_messages        = $pg ->{pgcore}->get_warning_messages();
    	$pgdebug_messages          = $pg ->{pgcore}->get_debug_messages();
    } else {
    	$internal_debug_messages = ['Error in obtaining debug messages from PGcore'];
    }
	# new version of output:
	my $out2   = {
		text 						=> encode_base64( $pg->{body_text}  ),
		header_text 				=> encode_base64( $pg->{head_text} ),
		answers 					=> $pg->{answers},
		errors         				=> $pg->{errors},
		WARNINGS	   				=> encode_base64( 
		                                 "WARNINGS\n".$warning_messages."\n<br/>More<br/>\n".$pg->{warnings} 
		                               ),
		problem_result 				=> $pg->{result},
		problem_state				=> $pg->{state},
		flags						=> $pg->{flags},
		warning_messages            => $pgwarning_messages,
		debug_messages              => $pgdebug_messages,
		internal_debug_messages     => $internal_debug_messages,
	};
	
	# Filter out bad reference types
	###################
	# DEBUGGING CODE
	###################
	if ($debugXmlCode) {
		my $logDirectory =$ce->{courseDirs}->{logs};
		my $xmlDebugLog  = "$logDirectory/xml_debug.txt";
		#warn "RenderProblem.pm: Opening debug log $xmlDebugLog\n" ;
		open (DEBUGCODE, ">>$xmlDebugLog") || die "Can't open debug log $xmlDebugLog";
		print DEBUGCODE "\n\nStart xml encoding\n";
	}
	
	$out2->{answers} = xml_filter($out2->{answers}); # check this -- it might not be working correctly
	##################
	close(DEBUGCODE) if $debugXmlCode;
	###################
	
	$out2->{flags}->{PROBLEM_GRADER_TO_USE} = undef;	
	
	
	$out2;
	         
}

#  insures proper conversion to xml structure.
sub xml_filter {
	my $input = shift;
	my $level = shift || 0;
	my $space="  ";
	# Hack to filter out CODE references
	my $type = ref($input);
	if (!defined($type) or !$type ) {
		print DEBUGCODE $space x $level." : scalar -- not converted\n" if $debugXmlCode;
	} elsif( $type =~/HASH/i or "$input"=~/HASH/i) {
		print DEBUGCODE "HASH reference with ".%{$input}." elements will be investigated\n" if $debugXmlCode;
		$level++;
		foreach my $item (keys %{$input}) {
			print DEBUGCODE "  "x$level."$item is " if $debugXmlCode;
		    $input->{$item} = xml_filter($input->{$item},$level);   
		}
		$level--;
		print DEBUGCODE "  "x$level."HASH reference completed \n" if $debugXmlCode;
	} elsif( $type=~/ARRAY/i or "$input"=~/ARRAY/i) {
		print DEBUGCODE "  "x$level."ARRAY reference with ".@{$input}." elements will be investigated\n" if $debugXmlCode;
		$level++;
		my $tmp = [];
		foreach my $item (@{$input}) {
			$item = xml_filter($item,$level);
			push @$tmp, $item;
		}
		$input = $tmp;
		$level--;
		print DEBUGCODE "  "x$level."ARRAY reference completed",join(" ",@$input),"\n" if $debugXmlCode;
	} elsif($type =~ /CODE/i or "$input" =~/CODE/i) {
		$input = "CODE reference";
		print DEBUGCODE "  "x$level."CODE reference, converted $input\n" if $debugXmlCode;
	} else {
		print DEBUGCODE  "  "x$level." $type and was  converted to string\n" if $debugXmlCode;
		$input = "$type reference";
	}
	$input;
	
}


sub logTimingInfo{
    my ($beginTime,$endTime,) = @_;
    my $out = "";
    $out .= Benchmark::timestr( Benchmark::timediff($endTime , $beginTime) );
    $out;
}


######################################################################
sub new {
#	my ($$ce, $user, $key, $set, $problem, $psvn, $formFields,
#		$translationOptions,$more_options) = @_;
#   called as a function not as a method
	
	my $renderer = 'WeBWorK::PG::Local2';
	#my $renderer = $ce->{pg}->{renderer};
	runtime_use $renderer;
	# the idea is to have Local call back to the defineProblemEnvir below.
	#return WeBWorK::PG::Local::new($renderer,@_);
	return $renderer->new(@_);
}


sub pretty_print2_rh { 
    shift if UNIVERSAL::isa($_[0] => __PACKAGE__);
	my $rh = shift;
	my $indent = shift || 0;
	my $out = "";
	my $type = ref($rh);

	if (defined($type) and $type) {
		$out .= " type = $type; ";
	} elsif (! defined($rh )) {
		$out .= " type = UNDEFINED; ";
	}
	return $out." " unless defined($rh);
	
	if ( ref($rh) =~/HASH/ or "$rh" =~/HASH/ ) {
	    $out .= "{\n";
	    $indent++;
 		foreach my $key (sort keys %{$rh})  {
 			$out .= "  "x$indent."$key => " . pretty_print2_rh( $rh->{$key}, $indent ) . "\n}\n";
 		}
 		$indent--;
 		$out .= "\n"."  "x$indent."}\n";

 	} elsif (ref($rh)  =~  /ARRAY/ or "$rh" =~/ARRAY/) {
 	    $out .= " [ ";
 		foreach my $elem ( @{$rh} )  {
 		 	$out .= pretty_print2_rh($elem, $indent).",";
 		
 		}
 		$out .=  "\n ] \n";
	} elsif ( ref($rh) =~ /SCALAR/ ) {
		$out .= "q{". ${$rh}."}";
	} elsif ( ref($rh) =~/Base64/ ) {
		$out .= "base64 reference " .$$rh;
	} else {
		$out .= "q{". $rh ."}";
	}
	
	return $out." ";
}


sub defineProblemEnvir {
	my (
		$self,
		$ce,
		$user,
		$key,
		$set,
		$problem,
		$psvn,  #FIXME  -- not used
		$formFields,
		$options,
		$extras,
	) = @_;
	
	my %envir;
	my $rh = $extras->{rh}; #externally defined environment
	# ----------------------------------------------------------------------
	
	# PG environment variables
	# from docs/pglanguage/pgreference/environmentvariables as of 06/25/2002
	# any changes are noted by "ADDED:" or "REMOVED:"
	
	# Vital state information
	# ADDED: displayModeFailover, displayHintsQ, displaySolutionsQ,
	#        refreshMath2img, texDisposition
	
	$envir{psvn}                = 4321 ;#$set->psvn;
	$envir{psvnNumber}          = "psvnNumber-is-deprecated-Please-use-psvn-Instead"; #FIXME
	$envir{probNum}             = 1; #$problem->problem_id;
#	$envir{questionNumber}      = $envir{probNum};
#	$envir{fileName}            = $problem->source_file;	 
	$envir{probFileName}        = $rh->{envir}->{probFileName};	 
	$envir{problemSeed}         = 1234; #$problem->problem_seed;
	$envir{displayMode}         = translateDisplayModeNames($options->{displayMode});
	$envir{languageMode}        = $envir{displayMode};	 
	$envir{outputMode}          = $envir{displayMode};	 
	$envir{displayHintsQ}       = $options->{showHints};	 
	$envir{displaySolutionsQ}   = $options->{showSolutions};
	$envir{texDisposition}      = "pdf"; # in webwork2, we use pdflatex
	
	# Problem Information
	# ADDED: courseName, formatedDueDate, enable_reduced_scoring
	
#	$envir{openDate}            = $set->open_date;
	$envir{formattedOpenDate}   = formatDateTime($envir{openDate}, $ce->{siteDefaults}{timezone});
	$envir{OpenDateDayOfWeek}   = formatDateTime($envir{openDate}, $ce->{siteDefaults}{timezone}, "%A", $ce->{siteDefaults}{locale});
	$envir{OpenDateDayOfWeekAbbrev} = formatDateTime($envir{openDate}, $ce->{siteDefaults}{timezone}, "%a", $ce->{siteDefaults}{locale});
	$envir{OpenDateDay}         = formatDateTime($envir{openDate}, $ce->{siteDefaults}{timezone}, "%d", $ce->{siteDefaults}{locale});
	$envir{OpenDateMonthNumber} = formatDateTime($envir{openDate}, $ce->{siteDefaults}{timezone}, "%m", $ce->{siteDefaults}{locale});
	$envir{OpenDateMonthWord}   = formatDateTime($envir{openDate}, $ce->{siteDefaults}{timezone}, "%B", $ce->{siteDefaults}{locale});
	$envir{OpenDateMonthAbbrev} = formatDateTime($envir{openDate}, $ce->{siteDefaults}{timezone}, "%b", $ce->{siteDefaults}{locale});
	$envir{OpenDateYear2Digit}  = formatDateTime($envir{openDate}, $ce->{siteDefaults}{timezone}, "%y", $ce->{siteDefaults}{locale});
	$envir{OpenDateYear4Digit}  = formatDateTime($envir{openDate}, $ce->{siteDefaults}{timezone}, "%Y", $ce->{siteDefaults}{locale});
	$envir{OpenDateHour12}      = formatDateTime($envir{openDate}, $ce->{siteDefaults}{timezone}, "%I", $ce->{siteDefaults}{locale});
	$envir{OpenDateHour24}      = formatDateTime($envir{openDate}, $ce->{siteDefaults}{timezone}, "%H", $ce->{siteDefaults}{locale});
	$envir{OpenDateMinute}      = formatDateTime($envir{openDate}, $ce->{siteDefaults}{timezone}, "%M", $ce->{siteDefaults}{locale});
	$envir{OpenDateAMPM}        = formatDateTime($envir{openDate}, $ce->{siteDefaults}{timezone}, "%P", $ce->{siteDefaults}{locale});
	$envir{OpenDateTimeZone}    = formatDateTime($envir{openDate}, $ce->{siteDefaults}{timezone}, "%Z", $ce->{siteDefaults}{locale});
	$envir{OpenDateTime12}      = formatDateTime($envir{openDate}, $ce->{siteDefaults}{timezone}, "%I:%M%P", $ce->{siteDefaults}{locale});
	$envir{OpenDateTime24}      = formatDateTime($envir{openDate}, $ce->{siteDefaults}{timezone}, "%R", $ce->{siteDefaults}{locale});
#	$envir{dueDate}             = $set->due_date;
	$envir{formattedDueDate}    = formatDateTime($envir{dueDate}, $ce->{siteDefaults}{timezone});
	$envir{formatedDueDate}     = $envir{formattedDueDate}; # typo in many header files
	$envir{DueDateDayOfWeek}    = formatDateTime($envir{dueDate}, $ce->{siteDefaults}{timezone}, "%A", $ce->{siteDefaults}{locale});
	$envir{DueDateDayOfWeekAbbrev} = formatDateTime($envir{dueDate}, $ce->{siteDefaults}{timezone}, "%a", $ce->{siteDefaults}{locale});
	$envir{DueDateDay}          = formatDateTime($envir{dueDate}, $ce->{siteDefaults}{timezone}, "%d", $ce->{siteDefaults}{locale});
	$envir{DueDateMonthNumber}  = formatDateTime($envir{dueDate}, $ce->{siteDefaults}{timezone}, "%m", $ce->{siteDefaults}{locale});
	$envir{DueDateMonthWord}    = formatDateTime($envir{dueDate}, $ce->{siteDefaults}{timezone}, "%B", $ce->{siteDefaults}{locale});
	$envir{DueDateMonthAbbrev}  = formatDateTime($envir{dueDate}, $ce->{siteDefaults}{timezone}, "%b", $ce->{siteDefaults}{locale});
	$envir{DueDateYear2Digit}   = formatDateTime($envir{dueDate}, $ce->{siteDefaults}{timezone}, "%y", $ce->{siteDefaults}{locale});
	$envir{DueDateYear4Digit}   = formatDateTime($envir{dueDate}, $ce->{siteDefaults}{timezone}, "%Y", $ce->{siteDefaults}{locale});
	$envir{DueDateHour12}       = formatDateTime($envir{dueDate}, $ce->{siteDefaults}{timezone}, "%I", $ce->{siteDefaults}{locale});
	$envir{DueDateHour24}       = formatDateTime($envir{dueDate}, $ce->{siteDefaults}{timezone}, "%H", $ce->{siteDefaults}{locale});
	$envir{DueDateMinute}       = formatDateTime($envir{dueDate}, $ce->{siteDefaults}{timezone}, "%M", $ce->{siteDefaults}{locale});
	$envir{DueDateAMPM}         = formatDateTime($envir{dueDate}, $ce->{siteDefaults}{timezone}, "%P", $ce->{siteDefaults}{locale});
	$envir{DueDateTimeZone}     = formatDateTime($envir{dueDate}, $ce->{siteDefaults}{timezone}, "%Z", $ce->{siteDefaults}{locale});
	$envir{DueDateTime12}       = formatDateTime($envir{dueDate}, $ce->{siteDefaults}{timezone}, "%I:%M%P", $ce->{siteDefaults}{locale});
	$envir{DueDateTime24}       = formatDateTime($envir{dueDate}, $ce->{siteDefaults}{timezone}, "%R", $ce->{siteDefaults}{locale});
#	$envir{answerDate}          = $set->answer_date;
	$envir{formattedAnswerDate} = formatDateTime($envir{answerDate}, $ce->{siteDefaults}{timezone});
	$envir{AnsDateDayOfWeek}    = formatDateTime($envir{answerDate}, $ce->{siteDefaults}{timezone}, "%A", $ce->{siteDefaults}{locale});
	$envir{AnsDateDayOfWeekAbbrev} = formatDateTime($envir{answerDate}, $ce->{siteDefaults}{timezone}, "%a", $ce->{siteDefaults}{locale});
	$envir{AnsDateDay}          = formatDateTime($envir{answerDate}, $ce->{siteDefaults}{timezone}, "%d", $ce->{siteDefaults}{locale});
	$envir{AnsDateMonthNumber}  = formatDateTime($envir{answerDate}, $ce->{siteDefaults}{timezone}, "%m", $ce->{siteDefaults}{locale});
	$envir{AnsDateMonthWord}    = formatDateTime($envir{answerDate}, $ce->{siteDefaults}{timezone}, "%B", $ce->{siteDefaults}{locale});
	$envir{AnsDateMonthAbbrev}  = formatDateTime($envir{answerDate}, $ce->{siteDefaults}{timezone}, "%b", $ce->{siteDefaults}{locale});
	$envir{AnsDateYear2Digit}   = formatDateTime($envir{answerDate}, $ce->{siteDefaults}{timezone}, "%y", $ce->{siteDefaults}{locale});
	$envir{AnsDateYear4Digit}   = formatDateTime($envir{answerDate}, $ce->{siteDefaults}{timezone}, "%Y", $ce->{siteDefaults}{locale});
	$envir{AnsDateHour12}       = formatDateTime($envir{answerDate}, $ce->{siteDefaults}{timezone}, "%I", $ce->{siteDefaults}{locale});
	$envir{AnsDateHour24}       = formatDateTime($envir{answerDate}, $ce->{siteDefaults}{timezone}, "%H", $ce->{siteDefaults}{locale});
	$envir{AnsDateMinute}       = formatDateTime($envir{answerDate}, $ce->{siteDefaults}{timezone}, "%M", $ce->{siteDefaults}{locale});
	$envir{AnsDateAMPM}         = formatDateTime($envir{answerDate}, $ce->{siteDefaults}{timezone}, "%P", $ce->{siteDefaults}{locale});
	$envir{AnsDateTimeZone}     = formatDateTime($envir{answerDate}, $ce->{siteDefaults}{timezone}, "%Z", $ce->{siteDefaults}{locale});
	$envir{AnsDateTime12}       = formatDateTime($envir{answerDate}, $ce->{siteDefaults}{timezone}, "%I:%M%P", $ce->{siteDefaults}{locale});
	$envir{AnsDateTime24}       = formatDateTime($envir{answerDate}, $ce->{siteDefaults}{timezone}, "%R", $ce->{siteDefaults}{locale});
#	$envir{numOfAttempts}       = ($problem->num_correct || 0) + ($problem->num_incorrect || 0);
	$envir{problemValue}        = 1;
	$envir{sessionKey}          = $key;
	$envir{courseName}          = $ce->{courseName};
#	$envir{enable_reduced_scoring} = $set->enable_reduced_scoring;
	
	# Student Information
	# ADDED: studentID
	
	$envir{sectionName}      = $rh->{envir}->{sectionName};
	$envir{sectionNumber}    = $rh->{envir}->{sectionNumber};
#	$envir{recitationName}   = $user->recitation;
	$envir{recitationNumber} = $envir{recitationName};
	$envir{setNumber}        = 0; #$set->set_id;
	$envir{studentLogin}     = $rh->{envir}->{studentLogin};
	$envir{studentName}      = $rh ->{envir}->{studentName}; #$user->first_name . " " . $user->last_name;
#	$envir{studentID}        = $user->student_id;
	$envir{permissionLevel}  = $options->{permissionLevel};  # permission level of actual user
	$envir{effectivePermissionLevel}  = $options->{effectivePermissionLevel}; # permission level of user assigned to this question
	
	
	# Answer Information
	# REMOVED: refSubmittedAnswers
	
	$envir{inputs_ref} = $formFields;
	
	# External Programs
	# ADDED: externalLaTeXPath, externalDvipngPath,
	#        externalGif2EpsPath, externalPng2EpsPath
	
	$envir{externalTTHPath}      = $ce->{externalPrograms}->{tth};
	$envir{externalLaTeXPath}    = $ce->{externalPrograms}->{latex};
	$envir{externalDvipngPath}   = $ce->{externalPrograms}->{dvipng};
	$envir{externalGif2EpsPath}  = $ce->{externalPrograms}->{gif2eps};
	$envir{externalPng2EpsPath}  = $ce->{externalPrograms}->{png2eps};
	$envir{externalGif2PngPath}  = $ce->{externalPrograms}->{gif2png};
	$envir{externalCheckUrl}     = $ce->{externalPrograms}->{checkurl};
	# Directories and URLs
	# REMOVED: courseName
	# ADDED: dvipngTempDir
	# ADDED: jsMathURL
	# ADDED: MathJaxURL
	# ADDED: asciimathURL
	# ADDED: macrosPath
	# REMOVED: macrosDirectory, courseScriptsDirectory
	# ADDED: LaTeXMathML
	
	$envir{cgiDirectory}           = undef;
	$envir{cgiURL}                 = undef;
	$envir{classDirectory}         = undef;
    $envir{macrosPath}             = $ce->{pg}->{directories}{macrosPath};
    $envir{appletPath}             = $ce->{pg}->{directories}{appletPath};
    $envir{pgDirectories}          = $ce->{pg}->{directories};
	$envir{webworkHtmlDirectory}   = $ce->{webworkDirs}->{htdocs}."/";
	$envir{webworkHtmlURL}         = $ce->{webworkURLs}->{htdocs}."/";
	$envir{htmlDirectory}          = $ce->{courseDirs}->{html}."/";
	$envir{htmlURL}                = $ce->{courseURLs}->{html}."/";
	$envir{templateDirectory}      = $ce->{courseDirs}->{templates}."/";
	$envir{tempDirectory}          = $ce->{courseDirs}->{html_temp}."/";
	$envir{tempURL}                = $ce->{courseURLs}->{html_temp}."/";
	$envir{scriptDirectory}        = undef;
	$envir{webworkDocsURL}         = $ce->{webworkURLs}->{docs}."/";
	$envir{localHelpURL}           = $ce->{webworkURLs}->{local_help}."/";
	$envir{jsMathURL}              = $ce->{webworkURLs}->{jsMath};
	$envir{MathJaxURL}             = $ce->{webworkURLs}->{MathJax};
	$envir{asciimathURL}	         = $ce->{webworkURLs}->{asciimath};
	$envir{LaTeXMathMLURL}	       = $ce->{webworkURLs}->{LaTeXMathML};
	$envir{server_root_url}        = $ce->{apache_root_url}|| '';
	
	# Information for sending mail
	
	$envir{mailSmtpServer} = $ce->{mail}->{smtpServer};
	$envir{mailSmtpSender} = $ce->{mail}->{smtpSender};
	$envir{ALLOW_MAIL_TO}  = $ce->{mail}->{allowedRecipients};
	
	# Default values for evaluating answers
	
	my $ansEvalDefaults = $ce->{pg}->{ansEvalDefaults};
	$envir{$_} = $ansEvalDefaults->{$_} foreach (keys %$ansEvalDefaults);
	
	# ----------------------------------------------------------------------
	
	# ADDED: ImageGenerator for images mode
	if (defined $extras->{image_generator}) {
		#$envir{imagegen} = $extras->{image_generator};
		# only allow access to the add() method
		$envir{imagegen} = new WeBWorK::Utils::RestrictedClosureClass($extras->{image_generator}, 'add','addToTeXPreamble', 'refresh');
	}
	
	if (defined $extras->{mailer}) {
		#my $rmailer = new WeBWorK::Utils::RestrictedClosureClass($extras->{mailer},
		#	qw/Open SendEnc Close Cancel skipped_recipients error error_msg/);
		#my $safe_hole = new Safe::Hole {};
		#$envir{mailer} = $safe_hole->wrap($rmailer);
		$envir{mailer} = new WeBWorK::Utils::RestrictedClosureClass($extras->{mailer}, "add_message");
	}
	
	#  ADDED: jsMath options
	$envir{jsMath} = {%{$ce->{pg}{displayModeOptions}{jsMath}}};
	
	# Other things...
	$envir{QUIZ_PREFIX}              = $options->{QUIZ_PREFIX}; # used by quizzes
	$envir{PROBLEM_GRADER_TO_USE}    = $ce->{pg}->{options}->{grader};
	$envir{PRINT_FILE_NAMES_FOR}     = $ce->{pg}->{specialPGEnvironmentVars}->{PRINT_FILE_NAMES_FOR};

        #  ADDED: __files__
        #    an array for mapping (eval nnn) to filenames in error messages
	$envir{__files__} = {
	  root => $ce->{webworkDirs}{root},     # used to shorten filenames
	  pg   => $ce->{pg}{directories}{root}, # ditto
	  tmpl => $ce->{courseDirs}{templates}, # ditto
	};
	
	# variables for interpreting capa problems and other things to be
        # seen in a pg file
	my $specialPGEnvironmentVarHash = $ce->{pg}->{specialPGEnvironmentVars};
	for my $SPGEV (keys %{$specialPGEnvironmentVarHash}) {
		$envir{$SPGEV} = $specialPGEnvironmentVarHash->{$SPGEV};
	}
	
	return \%envir;
}

sub translateDisplayModeNames($) {
	my $name = shift;
	return DISPLAY_MODES()->{$name};
}

1;
