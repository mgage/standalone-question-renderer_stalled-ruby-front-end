sub formatRenderedProblem {
	my $self 			  = shift;
	my $rh_result         = $self->{output}|| {};  # wrap problem in formats
	my $problemText       = "No output from rendered Problem";
	if (ref($rh_result) and $rh_result->{text} ) {
		$problemText       =  $rh_result->{text};
	} else {
		$problemText       = "Unable to decode problem text",format_hash_ref($rh_result);
	}
	my $rh_answers        = $rh_result->{answers};
	my $encodedSource     = $self->{encodedSource}||'encodedSourceIsMissing';
	my $warnings          = '';
	#################################################
	# regular Perl warning messages generated with warn
	#################################################

	if ( defined ($rh_result->{WARNINGS}) and $rh_result->{WARNINGS} ){
		$warnings = "<div style=\"background-color:pink\">
		             <p >WARNINGS</p><p>".decode_base64($rh_result->{WARNINGS})."</p></div>";
	}
	#warn "keys: ", join(" | ", sort keys %{$rh_result });
	
	#################################################	
	# PG debug messages generated with DEBUG_message();
	#################################################
	
	my $debug_messages = $rh_result->{debug_messages} ||     [];
    $debug_messages = join("<br/>\n", @{  $debug_messages }    );
    
	#################################################    
	# PG warning messages generated with WARN_message();
	#################################################

    my $PG_warning_messages =  $rh_result->{warning_messages} ||     [];
    $PG_warning_messages = join("<br/>\n", @{  $PG_warning_messages }    );
    
	#################################################
	# internal debug messages generated within PG_core
	# these are sometimes needed if the PG_core warning message system
	# isn't properly set up before the bug occurs.
	# In general don't use these unless necessary.
	#################################################

    my $internal_debug_messages = $rh_result->{internal_debug_messages} || [];
    $internal_debug_messages = join("<br/>\n", @{ $internal_debug_messages  } );
    
    my $fileName = $self->{input}->{envir}->{probFileName} || "Can't find file name";
	# collect answers
	my $answerTemplate    = q{<hr>ANSWERS <table border="3" align="center">};
	my $problemNumber     = 1;
    foreach my $key (sort  keys %{$rh_answers}) {
    	$answerTemplate  .= $self->formatAnswerRow($rh_answers->{$key}, $problemNumber++);
    }
	$answerTemplate      .= q{</table> <hr>};

	my $test = pretty_print($rh_result);
	my $XML_URL      = $self->url;
	my $FORM_ACTION_URL  =  $self->{form_action_url};
	my $courseID         =  $self->{courseID};
	my $userID           =  $self->{userID};
	my $session_key      =  $rh_result->{session_key};
	my $problemTemplate = <<ENDPROBLEMTEMPLATE;


<html>
<head>
<base href="$XML_URL">
<title>$XML_URL WeBWorK Editor using host $XML_URL</title>
</head>
<body>

<h2> WeBWorK Editor using host $XML_URL</h2>
		    $answerTemplate
		    <form action="$FORM_ACTION_URL" method="post">
			$problemText
	       <input type="hidden" name="answersSubmitted" value="1"> 
	       <input type="hidden" name="problemAddress" value="probSource"> 
	       <input type="hidden" name="problemSource" value="$encodedSource"> 
	       <input type="hidden" name="problemSeed" value="1234"> 
	       <input type="hidden" name="pathToProblemFile" value="$fileName">
	       <input type="hidden" name=courseName value="$courseID">
	       <input type="hidden" name=courseID value="$courseID">
	       <input type="hidden" name="userID" value="$userID">
	       <input type="hidden" name="session_key" value="$session_key">
	       <p><input type="submit" name="submit" value="submit answers"></p>
	     </form>
<HR>
<h3> Perl warning section </h3>
$warnings
<h3> PG Warning section </h3>
$PG_warning_messages;
<h3> Debug message section </h3>
$debug_messages
<h3> internal errors </h3>
$internal_debug_messages

</body>
</html>

ENDPROBLEMTEMPLATE



	$problemTemplate;
}

sub formatAnswerRow {
	my $self = shift;
	my $rh_answer = shift;
	my $problemNumber = shift;
	my $answerString  = $rh_answer->{original_student_ans}||'&nbsp;';
	my $correctAnswer = $rh_answer->{correct_ans}||'';
	my $ans_message   = $rh_answer->{ans_message}||'';
	my $score         = ($rh_answer->{score}) ? 'Correct' : 'Incorrect';
	my $row = qq{
		<tr>
		    <td>
				Prob: $problemNumber
			</td>
			<td>
				$answerString
			</td>
			<td>
			    $score
			</td>
			<td>
				Correct answer is $correctAnswer
			</td>
			<td>
				<i>$ans_message</i>
			</td>
		</tr>\n
	};
	$row;
}