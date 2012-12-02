#!/usr/bin/perl -w
use strict;
use MIME::Base64 qw( encode_base64 decode_base64);


require "data/data_input_to_PG_generator.txt" || die "can't find data";

$main::rh_input->{source} = decode_base64($main::rh_input->{source} );

print pretty_print2_rh($main::rh_input);



sub pretty_print2_rh { 
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
 			$out .= "  "x$indent."$key => " . pretty_print2_rh( $rh->{$key}, $indent ).",\n" ;
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