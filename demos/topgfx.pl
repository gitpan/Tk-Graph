#!/usr/local/bin/perl -w

use lib '../.';

use strict;
use Carp;
use Tk;
use Tk::Graph;
use Tk::BrowseEntry;
use Tk::NumEntry;

use DBI;
use Data::Dumper;

# Dump all the information
# in the current process table
use Proc::ProcessTable;
my $t = Proc::ProcessTable->new;

my $mw = MainWindow->new;

my %data;
my $typ = 'HBARS';
my $field = 'pctcpu';

my $fc = $mw->Frame(
	-borderwidth	=> 1,
	-width      	=> 500,
	-height     	=> 200 
);


my $cc = $fc->Graph(
	-type		=> $typ,
	-borderwidth	=> 2,
	-title		=> 'Top Processes',
	-titlecolor	=> 'Brown',
	-yformat	=> '%2.2f',

#	-ylabel		=> 'cpu',
#	-xlabel		=> 'seconds',

        -barwidth 	=> 15,
	-padding	=> [20,20,20,100],	# Padding [top, right, buttom, left]
	-linewidth	=> 1,
	-shadow		=> 'gray50',
	-shadowdepth	=> 3,
	-maxmin		=> 1,
	-look		=> 50,
	-balloon	=> 1,
	-legend		=> 1,
	)->pack(-expand => 1, -fill => 'both');


# Button Frame
my $fra = $mw->Frame();

# Typ
my $opt = $fra->BrowseEntry(
	-options  	=> ['BARS', 'HBARS', 'CIRCLE', 'LINE'],
	-variable 	=> \$typ,
	-command  	=> sub { 
			$cc->configure(-type => uc($typ));
			$cc->redraw();
		},
	)->pack(-side => 'left');

# Field
my @fields = $t->fields;
@fields = sort grep(! /^$/, @fields);

my $fie = $fra->BrowseEntry(
	-options  	=> \@fields,
	-variable 	=> \$field,
	-command  	=> sub { 
			$cc->configure(-ylabel => $field);
			$cc->clear();
		},
	)->pack(-side => 'left');

my $threed = 0;
my $thr = $fra->NumEntry(
	-textvariable 	=> \$threed,
	-minvalue	=> 0,
	-maxvalue	=> 50,
	)->pack(-side => 'left');

my $gbu = $fra->Button(
	-text 		=> '3D', 
	-command 	=> sub { 
				$cc->configure(-threed => $threed);
				$cc->redraw;
			},
	)->pack(-side => 'left');

# Packs
$fc ->pack(-expand => 1, -fill => 'both', -anchor => 'nw', -side => 'top');
$fra->pack(-expand => 1, -fill => 'both', -anchor => 'nw', -side => 'top');



# Daten holen und dem Widget zuschieben
refresh(\%data, $cc);

# ... und das alle X Sekunden
NOCHMA:
$mw->after(5000, sub{ 
	&refresh(\%data, $cc, $field);
	goto NOCHMA;
} );

MainLoop;
exit;

# Subs ----------------------------------

sub refresh {
	my $data = shift 	|| warn 'Keine Daten!';
	my $widget = shift 	|| warn 'Kein Widget!';
	my $field = shift 	|| return;

	foreach my $p (@{$t->table}) {
		if($p->{ $field }>0) {
			$$data{$p->{fname}} = $p->{$field};
		} else {
			delete $data->{$p->{fname}}
				if(defined $data->{$p->{fname}});
		}
	}   
	$widget->set(\%data);
}

         
