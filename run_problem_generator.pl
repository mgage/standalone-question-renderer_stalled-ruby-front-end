#!/usr/bin/perl -w
use strict;
package WWRenderer;
use lib "webwork2/lib";
use lib "pg/lib";
use lib ".";

use WebworkClient;

use vars qw($HOST_NAME $HOST_PORT $WW_DIRECTORY  $PG_DIRECTORY $SeedCE 
	$SITE_PASSWORD $COURSENAME );
use MIME::Base64 qw( encode_base64 decode_base64);

BEGIN {
    $main::VERSION = "2.5.1";
    #use Cwd;
	

	#use constant MP2 => ( exists $ENV{MOD_PERL_API_VERSION} and $ENV{MOD_PERL_API_VERSION} >= 2 );

###############################################################################
# Configuration -- set to top webwork directory (webwork2) (set in webwork.apache2-config)
# Configuration -- set server name
###############################################################################

    my $webwork_directory = 'webwork2';
    $WeBWorK::Constants::WEBWORK_DIRECTORY = $webwork_directory;
	print "\nwebwork_directory set to $webwork_directory\n";
	

	$WWRenderer::HOST_NAME     = 'localhost'; # Apache->server->server_hostname;
	$WWRenderer::HOST_PORT     = '80';        # Apache->server->port;

###############################################################################

	eval "use lib '$webwork_directory/lib'"; die $@ if $@;
	eval "use WeBWorK::CourseEnvironment"; die $@ if $@;
 	my $seed_ce = new WeBWorK::CourseEnvironment(
 		{ webwork_dir => $webwork_directory ,
 		  courseName  => "gage_demo",
 		});
 	die "Can't create seed course environment for webwork in $webwork_directory" unless ref($seed_ce);
 	my $webwork_url = $seed_ce->{webwork_url};
 	my $pg_dir = $seed_ce->{pg_dir};
 	eval "use lib '$pg_dir/lib'"; die $@ if $@;
    
	$WWRenderer::WW_DIRECTORY = $webwork_directory;
	$WWRenderer::PG_DIRECTORY = $pg_dir;
	$WWRenderer::SeedCE       = $seed_ce;
	
###############################################################################

	$WWRenderer::SITE_PASSWORD      = 'xmluser';     # default password
	$WWRenderer::COURSENAME    = 'the-course-should-be-determined-at-run-time';       # default course
	
	

}
use RenderProblem;
use WeBWorK::PG::Local2;

#########################################################################
# $ce = WeBWorK::CourseEnvironment->new({
#  	webwork_url         => "/webwork2",
#  	webwork_dir         => "/opt/webwork2",
#  	pg_dir              => "/opt/pg",
#  	webwork_htdocs_url  => "/webwork2_files",
#  	webwork_htdocs_dir  => "/opt/webwork2/htdocs",
#  	webwork_courses_url => "/webwork2_course_files",
#  	webwork_courses_dir => "/opt/webwork2/courses",
#  	courseName          => "name_of_course",
#  });
 

$main::rh_input=undef;
do "data/data_input_to_PG_generator.txt" || die "can't find data";


my $out = RenderProblem::renderProblem($main::rh_input);

$out->{text} = decode_base64($out->{text});
#$out->{WARNINGS}= decode_base64{$out->{WARNINGS}};

my $xmlrpc_client = new WebworkClient();
$xmlrpc_client->{output} = $out;
my $out2 = $xmlrpc_client->formatRenderedProblem;
#print $out;
print $out2;

sub pretty_print_rh { 
    shift if UNIVERSAL::isa($_[0] => __PACKAGE__);
	my $rh = shift;
	my $indent = shift || 0;
	my $out = "";
	my $type = ref($rh);

	return $out." " unless defined($rh);
	
	if ( ref($rh) =~/HASH/ or "$rh" =~/HASH/ ) {
	    $out .= "{\n";
	    $indent++;
 		foreach my $key (sort keys %{$rh})  {
 			$out .= "  "x$indent."$key => " . pretty_print_rh( $rh->{$key}, $indent ) . "\n";
 		}
 		$indent--;
 		$out .= "\n"."  "x$indent."}\n";

 	} elsif ( ( ref($rh)  =~  /ARRAY/  )) {
 	    $out .= " ( ";
 		foreach my $elem ( @{$rh} )  {
 		 	$out .= pretty_print_rh($elem, $indent);
 		
 		}
 		$out .=  " ) \n";
	} elsif ( ref($rh) =~ /SCALAR/ ) {
		$out .= "scalar reference ". ${$rh};
	} elsif ( ref($rh) =~/Base64/ ) {
		$out .= "base64 reference " .$$rh;
	} else {
		$out .=  $rh;
	}
	
	return $out." ";
}


sub pretty_print2_rh { 
    shift if UNIVERSAL::isa($_[0] => __PACKAGE__);
	my $rh = shift;
	my $indent = shift || 0;
	my $out = "";
	my $type = ref($rh);

# 	if (defined($type) and $type) {
# 		$out .= " type = $type; ";
# 	} elsif (! defined($rh )) {
# 		$out .= " type = UNDEFINED; ";
# 	}
	return $out." " unless defined($rh);
	
	if ( ref($rh) =~/HASH/ or "$rh" =~/HASH/ ) {
	    $out .= "{\n";
	    $indent++;
 		foreach my $key (sort keys %{$rh})  {
 			$out .= "  "x$indent."$key => " . pretty_print_rh( $rh->{$key}, $indent ) . "\n}\n";
 		}
 		$indent--;
 		$out .= "\n"."  "x$indent."}\n";

 	} elsif (ref($rh)  =~  /ARRAY/ ) {
 	    $out .= " [ ";
 		foreach my $elem ( @{$rh} )  {
 		 	$out .= pretty_print_rh($elem, $indent).",";
 		
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


1;