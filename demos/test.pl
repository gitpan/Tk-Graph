#!/usr/local/bin/perl -w

use strict;

use Tk;
use Tk::Graph; 

my $mw = MainWindow->new;

my $data;

$data = {
	'one'  => 20,
	'two' => 15,
	'three' => 21,
};



my $ca = $mw->Graph(
	-type		=> 'Bars',
	-shadowdepth	=> 4,

	-xlabel		=> 'xlabel',
	-xformat	=> '%s',

	-ylabel		=> 'ylabel',

	-printvalue	=> '%s: %g',
	)->pack(-expand => 1, 
		-fill => 'both');

$ca->variable($data);	# Auf Daten anzeigen

$mw->after(2000, sub { shuffle($data, $ca) } );

MainLoop;

sub shuffle {
	my $data = shift || die;
	my $ca = shift || die;

	foreach my $n (keys %$data) {
		$data->{$n} = int( rand(100) );		
	}
	$mw->after(1000, sub { shuffle($data, $ca) } );
}
                                                                             
