#------------------------------------------------
# automagically updated versioning variables -- CVS modifies these!
#------------------------------------------------
our $Revision           = '$Revision: 1.14 $';
our $CheckinDate        = '$Date: 2002/09/05 19:24:08 $';
our $CheckinUser        = '$Author: xpix $';
# we need to clean these up right here
$Revision               =~ s/^\$\S+:\s*(.*?)\s*\$$/$1/sx;
$CheckinDate            =~ s/^\$\S+:\s*(.*?)\s*\$$/$1/sx;
$CheckinUser            =~ s/^\$\S+:\s*(.*?)\s*\$$/$1/sx;
#-------------------------------------------------
#-- package Tk::Graph ----------------------------
#-------------------------------------------------

=head1 NAME

Tk::Graph - A graphical Chartmaker at Canvas (Realtime). This is a real Canvaswidget, 
also you can draw with the standart routuines in this canvas object. 
In an example, you can draw a line with I<$chart>->I<line(x,y,...)>. Is importand for you when you will
add a logo or write a text in your created Chart.

=head1 SYNOPSIS

use Tk;
use Tk::Graph; 

my $mw = MainWindow->new;

my $data = {
sleep   => 51, 
Work    => 135, 
Access  => 124, 
MySQL   => 5
};

my $ca = $mw->Graph(
   -type  => 'BARS',
)->pack(
   -expand => 1,
   -fill => 'both',
);

$ca->configure(-variable => $data);     # bind to data

# or ...

$ca->set($data);        # set data

MainLoop;

=cut

# -------------------------------------------------------
#
# Graph.pm
#
# A graphical Chartmaker at Canvas (Realtime)
# -------------------------------------------------------
package Tk::Netzwert::Graph;

use English;
use Carp;
use base qw/Tk::Derived Tk::Canvas/;
use Tk::Trace;
use Tk::Balloon;
# eval "use Tk::CanvasBalloon";
my $eerror = 1 if($EVAL_ERROR);
use strict;

Construct Tk::Widget 'Graph';

#-------------------------------------------------
sub Populate {
#-------------------------------------------------
my ($self, $args) = @_;
$self->SUPER::Populate($args);

=head1 WIDGET-SPECIFIC OPTIONS

=cut

my %specs;

#-------------------------------------------------
$specs{-debug} 		= [qw/PASSIVE debug        Debug/,             undef];

=head2 -debug [I<0>|1]

This is the Switch for debug output at the normal console (STDOUT)

=cut

#-------------------------------------------------
$specs{-type}  		= [qw/PASSIVE type         Type/,		undef];

=head2 -type (I<Automatic>, Line, Bars, HBars, Circle)

This if the type to display the data.

I<Automatic> - analyze the datahash and choice a Chart:

Hash with values -> CircleChart 
Hash with keys with hashes or values (not all) -> Barchart pro Key 
Hash with keys with arrays -> Linechart pro Key 
Array -> Linechart 

I<Line> - Linechart,

I<Bars> - Barchart with vertical Bars,

I<HBars> - Barchart with horizontal bars,

I<Circle> - Circlechart

=cut

#-------------------------------------------------
$specs{-foreground} 	= [qw/PASSIVE foreground   Foreground/,	'black'];

=head2 -foreground (I<black>)

Color from the Axis, Legend and Labels.

=cut

#-------------------------------------------------
$specs{-titlecolor}     = [qw/PASSIVE titlecolor   TitleColor          brown/];
$specs{-title}     	= [qw/PASSIVE title        Title/,             ' '];

=head2 -title -titlecolor (I<brown>)

Message top at the Widget

=cut

#-------------------------------------------------
$specs{-headroom}     	= [qw/PASSIVE headroom     HeadRoom/,          20];

=head2 -headroom  (I<20>)

The Headroom in percent. 

=cut

#-------------------------------------------------
$specs{-max}     	= [qw/PASSIVE max          Max/,               undef];

=head2 -max

Maximum Value at the axis,
this make the axis not dynamicaly redraw to the
next maximums value from the highest value in the data. 
If only with function in Lines and Bars!

=cut

#-------------------------------------------------
$specs{-sortnames}     	= [qw/PASSIVE sortnames	   SortNames/,         'alpha'];
$specs{-sortreverse}    = [qw/PASSIVE sortreverse  SortReverse/,      	undef];

=head2 -sortnames ('I<alpha>' | 'num') -sortreverse (0, 1)

sort the keys from the datahash.

=cut

#-------------------------------------------------
$specs{-config}    	= [qw/PASSIVE config       Config/,            undef];

=head2 -config (\%cfghash)

A confighash with optional added parameters for more flexibility. The first is the name 
of the key from youre datahash, following from
a confighash with parameters.
example:

        -config         => {
        	'fr' => {
        		-title => 'Free',
        		-color => 'green',
        	},
                'sl' => {
                	-title => 'Sleep',
                	-color => 'yellow',
                },
                ...
        },

I<-title>

Here you can write a other Name to display

I<-color>

key only display in this color

=cut

#-------------------------------------------------
$specs{-fill}     	= [qw/PASSIVE fill         Fill/,              'both'];

=head2 -fill (I<'both'>)

The same we in perl/tk pack, the redraw only new in 
I<x>,I<y> direction or I<both>

=cut

#-------------------------------------------------
$specs{-ylabel}     	= [qw/PASSIVE ylabel	    YLabel/,		undef];
$specs{-xlabel}     	= [qw/PASSIVE xlabel	    XLabel/,		undef];

=head2 -xlabel -ylabel (I<text>)

This display a Description for x and y axis

=cut

#-------------------------------------------------
$specs{-ytick}     	= [qw/PASSIVE ytick	    YTick/,		5];
$specs{-xtick}     	= [qw/PASSIVE xtick	    XTick/,		5];

=head2 -xtick -ytick (I<5>)

How many ticks at the x or y axis?

=cut

#-------------------------------------------------
$specs{-yformat}     	= [qw/PASSIVE yformat	    YFormat/,		'%g'];
$specs{-xformat}     	= [qw/PASSIVE xformat	    XFormat/,		'%s'];

=head2 -xformat (I<'%s'>) -yformat (I<'%g'>)

This if the sprintf format for dislplay
value or key at the axis.
example:

        -xformat => '%d%%'      # This will i.e. Display '50%'
        -yformat => '%s host'   # This will i.e. Display 'first host'

=cut

#-------------------------------------------------
$specs{-padding}     	= [qw/PASSIVE padding	    Padding/,		[15,20,20,50]];

=head2 -padding (I<[15,20,20,50]>)

Margin display from the widgetborder, in this direction top, right, bottom,
left 

=cut

#-------------------------------------------------
$specs{-linewidth}     	= [qw/PASSIVE linewidth    Linewidth           1/];

=head2 -linewidth (I<1>)

The weight from the Border at the dots, circle, lines 

=cut


#-------------------------------------------------
$specs{-printvalue}     = [qw/PASSIVE printvalue   Printvalue/,        undef];

=head2 -printvalue 

This if the sprintf format for display value and a 
switch for the last values from the datahash 

=cut

#-------------------------------------------------
$specs{-maxmin}     	= [qw/PASSIVE maxmin       MaxMin/,            undef];

=head2 -maxmin 

Draw Max/Average/Min values Lines in the Bars and 
Line charts 

=cut

#-------------------------------------------------
$specs{-legend}     	= [qw/PASSIVE legend       Legend/,            1];

=head2 -legend [0|I<1>] 

Switch on/off the legend in Circle or Lines  

=cut

#-------------------------------------------------
$specs{-colors}     	= [qw/PASSIVE colors       Colors/,            'blue,brown,seashell3,red,green,yellow,darkgreen,darkblue,darkred,orange,olivedrab,magenta,black,salmon'];

=head2 -colors (I<red, green, ...>) 

A comma-separated list with the allows colors 
  

=cut

#-------------------------------------------------
$specs{-shadow}     	= [qw/PASSIVE shadow       Shadow/,            'gray50'];
$specs{-shadowdeep}    	= [qw/PASSIVE shadowdeep   ShadowDeep/,        undef];

=head2 -shadow (I<'gray50'>) -shadowdeep (I<0>) 

You can add a shadow to all Charts, the
switch is -shadowdeep. 
This is also the deep in Pixel from the shadow.
-shadow is the color from the Shadow.  

=cut

#-------------------------------------------------
$specs{-wire}     	= [qw/PASSIVE wire         Wire/,              'white'];

=head2 -wire (I<'white'>)

Switch on/off to draw a wire in background from Line 
and bars chart.

=cut

#-------------------------------------------------
$specs{-reference}     	= [qw/PASSIVE reference    Reference/,         undef];

=head2 -reference (I<'name'>, I<'value'>) 

This give a
Referencevalue for the keys in datahash.
example:

        -reference      => 'Free, 1024',        # Free space at host

=cut

#-------------------------------------------------
$specs{-look}     	= [qw/PASSIVE look         Look/,              undef];

=head2 -look (I<'count'>) 

A Count to follow the values in linechart, when you refresh 
the datahash then this will display ex. 50 values from the
keys only in linechart.
example:

        -look   => 50,  # 50 values to display pro key

=cut

#-------------------------------------------------
$specs{-dots}     	= [qw/PASSIVE dots         Dots/,              undef];

=head2 -dots (I<'width'>) 

The width and switch
on from the Dots in linechart 

=cut

#-------------------------------------------------
$specs{-barwidth}     	= [qw/PASSIVE barwidth     Barwidth/,          30];

=head2 -barwidth (I<30>) 

The width from Bars in Barcharts

=cut

#-------------------------------------------------
$specs{-balloon}     	= [qw/PASSIVE balloon      Balloon/,           1];

=head2 -ballon (0|I<1>) 

Switch on/off a BallonHelp to segementes or lines. 
The Text is use from the -printvalue option.

=cut

#-------------------------------------------------
$specs{-font}     	= [qw/PASSIVE font	    Font/,		'-*-Helvetica-Medium-R-Normal--*-100-*-*-*-*-*-*'];

=head2 -font (I<'-*-Helvetica-Medium-R-Normal--*-100-*-*-*-*-*-*'>)

Draw text in font

=cut

#-------------------------------------------------
$specs{-lineheight}     = [qw/PASSIVE lineheight   LineHeight/,	15];

=head2 -lineheight (I<15>)

The Lineheight in pixel from text in the legend

=cut

#-------------------------------------------------


=head1 METHODS

Here come the Methodes that can you use for this Widget.

=cut


#-------------------------------------------------

#-------------------------------------------------
$specs{-set}     	= [qw/METHOD  set          Set/,               undef];

=head2 $chart->I<set>($data);

Set the datahash to display.

=cut

#-------------------------------------------------
$specs{-variable}     	= [qw/METHOD  variable     Variable/,          undef];

=head2 $chart->I<variable>($data);

bind the datahash to display the data, write to $data will redraw the widget.

=cut

#-------------------------------------------------
$specs{-redraw}     	= [qw/METHOD  redraw       Redraw/,            undef];

=head2 $chart->I<redraw>();

Redraw chart

=cut

#-------------------------------------------------
$specs{-clear}     	= [qw/METHOD  clear        Clear/,             undef];

=head2 $chart->I<redraw>();

Clear the canvas

=cut


        $self->ConfigSpecs(
		%specs,
        );

        # Bindings
        $self->Tk::bind('<Configure>', sub{ $self->redraw() } );                # Redraw

        # Help (CanvasBalloon)
        $self->{balloon} = $self->Balloon
        	unless($eerror);

} # end Populate

#-------------------------------------------------
sub draw_horizontal_bars {
#-------------------------------------------------
        my $self = shift || return error("No Objekt!");
	return undef unless(ref $self eq __PACKAGE__);
        my $data = shift || return error("No Data!");

	# Check
	return warn("Your data is incorrect, i need a Hashreference!")
		unless(ref $data eq 'HASH');


        my $werte = $self->reference($data);
        my $conf = $self->ReadConfig($werte) || return;

        $self->delete('all');

        # MaxMin Werte ermitteln und ggf Linien zeichnen
        $self->maxmin($conf, $werte);

        # Gitter zeichnen
        $self->wire($conf)
                if( $self->cget(-wire) );

        # Axis (Titel ... usw
        $self->axis($conf, $werte);


        $self->debug("Count: %d,Typ: %s, Max: %s", $conf->{count}, $conf->{typ}, $conf->{max_value});
        if($conf->{count} > 0 && $conf->{typ} eq 'HASH' && $conf->{max_value} > 0)
        {
                my $i = -0.5;
                my @linepoints;
                my $c;
		my $shadowcolor = $self->cget(-shadow);
		my $sd = $self->cget(-shadowdeep);

                foreach my $point (sort { $self->sorter } keys %$werte ) {
                        next if(ref $werte->{$point});
                        next unless($conf->{max_value});
                        $i++;

                        my $xi = ($conf->{x_null} + int(( ($conf->{width} - $conf->{x_null}) / $conf->{max_value} ) * $werte->{$point}));
                        my $yi = ($conf->{y_null}) - (int(($conf->{y_null} - $conf->{ypad}) / $conf->{count} + 0.99) * $i);
                        $yi-=($self->cget(-barwidth) / 2);

                        # Values
                        $self->createText($xi+12, $yi + ($self->cget(-barwidth) / 2),
                                -text => sprintf($self->cget(-printvalue), $werte->{$point}),
                                -anchor => 'w',
                                -font => $conf->{font},
                                -fill => $self->cget(-titlecolor)
                                        ) if($self->cget(-printvalue));


                        # Shadow Bar
                        if($sd && $werte->{$point}) {
                                my $bar = $self->createRectangle(
                                                ($xi+$sd), ($yi+$sd),
                                                ($conf->{x_null}), ($yi + $self->cget(-barwidth) + $sd),
                                        -fill => $shadowcolor,
                                        -outline => $shadowcolor,
                                        );
                        }

                        # Normaler Bar
                        $self->{elements}->{$point} = $self->createRectangle($xi, $yi,
                                $conf->{x_null}, ($yi + $self->cget(-barwidth)),
                                -fill => $self->{colors}->{$point},
                                -width => 1,
                                        );
                }

        # balloon
        $self->balloon($self->{elements}, $werte);

        }
}


#-------------------------------------------------
sub draw_bars {
#-------------------------------------------------
        my $self = shift || return error("No Objekt!");
	return undef unless(ref $self eq __PACKAGE__);
        my $data = shift || return error("No Data!");

	# Check
	return warn("Your data is incorrect, i need a Hashreference!")
		unless(ref $data eq 'HASH');

        my $werte = $self->reference($data);
        my $conf = $self->ReadConfig($werte) || return;

        $self->delete('all');

        # MaxMin Werte ermitteln und ggf Linien zeichnen
        $self->maxmin($conf, $werte);

        # Gitter zeichnen
        $self->wire($conf)
                if( $self->cget(-wire) );

        # Axis (Titel ... usw
        $self->axis($conf, $werte);



        if($conf->{count} > 0 && $conf->{typ} eq 'HASH')
        {
                my $i = -1;
                my ($xi, $yi);
                my @linepoints;
                my $c;
                foreach my $point (sort { $self->sorter } keys %$werte ) {
                        next if(ref $werte->{$point});
                        next unless($conf->{max_value});
                        $i++;
                        $xi = ($conf->{x_null} + $self->cget(-barwidth)) + ((int(($conf->{width}-$conf->{x_null})/$conf->{count}) + 0.99) * $i);
                        $yi = ($conf->{y_null}) - int( ( ( $conf->{y_null} - $conf->{ypad_top} ) / $conf->{max_value} ) * $werte->{$point} );
                        $xi = $xi - ($self->cget(-barwidth) / 2);

                        unless(ref $werte->{$point}) {
                                # Values
                                $self->createText($xi+12, $yi-12,
                                        -text => sprintf($self->cget(-printvalue), $werte->{$point}),
                                        -anchor => 'n',
                                        -font => $conf->{font},
                                        -fill => $self->cget(-titlecolor)
                                                ) if($self->cget(-printvalue));


                                # Shadow Bar
                                if($werte->{$point} && $self->cget(-shadowdeep) && (my $shadowcolor = $self->cget(-shadow)) && (my $sd = $self->cget(-shadowdeep))) {
	                                $self->createRectangle(
                                                ($xi+$sd), ($yi+$sd),
                                                ($xi + $self->cget(-barwidth)+$sd), $conf->{y_null},
	                                        -fill => $shadowcolor,
	                                        -outline => $shadowcolor,
	                                 );
                                }

                                # Normaler Bar
                                $self->{elements}->{$point} = $self->createRectangle(
                                		$xi, $yi,
	                                        ($xi + $self->cget(-barwidth)), $conf->{y_null},
	                                        -fill => $self->{colors}->{$point},
	                                        -width => 1,
                                          );
                        }
                }
        } else {
                return warn "I need a hash to display Bars!";
        }

        # balloon
        $self->balloon($self->{elements}, $werte);
}


#-------------------------------------------------
sub draw_line {
#-------------------------------------------------
        my $self = shift || return error("No Objekt!");
	return undef unless(ref $self eq __PACKAGE__);
        my $data = shift || return error("No Data!");
        my $werte = $self->reference($data);
        my $conf = $self->ReadConfig($werte) || return;
        my $MAX;

        $self->delete('all');

        # Zeitverfolgung
        $self->look($werte);

        # MaxMin Werte ermitteln und ggf. Linien zeichnen
        $self->maxmin($conf, $werte);

        # Gitter zeichnen
        $self->wire($conf);

        # Axis (Titel ... usw
        $self->axis($conf, $werte);




        if( $conf->{count} > 0 && ( $conf->{typ} eq 'HASH' || $self->cget(-look)))
        {
                my $z = 0;
		my $data = ($self->cget(-look) ? $self->{look} : $werte); 
		my $w;
		
                foreach my $name (sort { $self->sorter } keys %{$data}) {
                        my @linepoints;
                        my $i = 0;
                        my ($xi, $yi);
                        my $lastpoint;

                        foreach my $point (@{$data->{$name}}) {
                                $xi = $conf->{x_null} + ((int(($conf->{width} - $conf->{x_null})/$conf->{count}) + 0.99) * $i++);
                                push(@linepoints, $xi);
                                $yi = $conf->{y_null} - int((($conf->{y_null} - $conf->{ypad_top})/$conf->{max_value}) * $point);
                                push(@linepoints, $yi);

                                # Values
                                $self->createText($xi+12, $yi-12,
                                        -text => sprintf($self->cget(-printvalue), $name, $point),
                                        -anchor => 'n',
                                        -font => $conf->{font},
                                        -fill => $self->cget(-titlecolor)
                                                ) if($self->cget(-printvalue));

                                # Dots
                                $self->createRectangle($xi-$self->cget(-dots), $yi-$self->cget(-dots),
                                        $xi+$self->cget(-dots), $yi+$self->cget(-dots),
                                        -fill => 'gray65',
                                        -width => 1,
                                                ) if($self->cget(-dots));
                                $lastpoint = $point;
                        }

                        # Graph Line
                        $self->{elements}->{$name} = $self->createLine(@linepoints,
                                -width => $self->cget(-linewidth),
                                -fill => $self->{colors}->{$name},
                                 );
                }

	        # balloon
	        $self->balloon($self->{elements}, $werte);

		# Legend
		$self->legend($data, $conf);
        }
        elsif($conf->{typ} eq 'HASH')
        {
                my @linepoints;
                my $i = 0;
                my ($xi, $yi);
                foreach my $point (sort { $self->sorter } keys %$werte ) {
                        $xi = ($conf->{x_null} + $self->cget(-barwidth)) + (int(( $conf->{width} - $conf->{x_null} ) / $conf->{count} + 0.99) * $i++);

                        push(@linepoints, $xi);
                        $yi = ($conf->{y_null}) - int((($conf->{y_null})/$conf->{max_value}) * $werte->{$point});
                        push(@linepoints, $yi);

                        # Values
                        $self->createText($xi+12, $yi-12,
                                -text => sprintf($self->cget(-printvalue), $werte->{$point}),
                                -anchor => 'n',
                                -font => $conf->{font},
                                -fill => $self->cget(-titlecolor)
                                        ) if($self->cget(-printvalue));

                        if($self->cget(-dots)) {
                                # Dots
                                my $dot = $self->createRectangle($xi-$self->cget(-dots), $yi-$self->cget(-dots),
                                        $xi+$self->cget(-dots), $yi+$self->cget(-dots),
                                        -fill => 'gray65',
                                        -width => 1,
                                                );
                                # balloon
                                $self->balloon($dot, $point, $werte->{$point});
                        }
                }

                # Graph Line
                my $item = $self->createLine(@linepoints,
                        -width => $self->cget(-linewidth) );
        }
}


#-------------------------------------------------
sub redraw {
#-------------------------------------------------
        my $self = shift || return error("No Objekt!");
	return undef unless(ref $self eq __PACKAGE__);
        $self->debug('Redraw');
        $self->set( $self->{data} );
}


#-------------------------------------------------
sub automatic {
#-------------------------------------------------
        my $self = shift || return error("No Objekt!");
	return undef unless(ref $self eq __PACKAGE__);
        my $data = shift;
        $data = ( $data ? $data : $self->{data} );
	my $type;

	if(ref $data eq 'ARRAY') {
		$type = 'LINE'
	} elsif (ref $data eq 'HASH') {
		foreach my $n (keys %$data) {
			if(ref $data->{$n} eq 'ARRAY') {
				$type = 'LINE';
				last;
			} elsif (ref $data->{$n} eq 'HASH'){
				$type = 'BARS';
				last;
			} else {
				$type = 'CIRCLE';				
				last;
			}
		}
	}
	return $type;
}

#-------------------------------------------------
sub set {
#-------------------------------------------------
        my $self = shift || return error("No Objekt!");
	return undef unless(ref $self eq __PACKAGE__);
        my $data = shift;
        $data = ( $data ? $data : $self->{data} );

        return unless(defined $data and ref $data eq "HASH" and scalar keys %$data);
	return unless($self->width || $self->height); 

	# Make a LineGraph
	if(ref $data eq 'ARRAY') {
		my $werte;
		$werte->{' '} = $data;
		$data = $werte;
	}

	my $autom = $self->automatic( $data );
	my $type  = uc($self->cget(-type)); 

	$self->debug('Automatic: %s, User: %s',
		$autom, $type);

        $self->{data} = $data;

        if( $type eq 'LINE' ) {
                $self->draw_line($data);

        } elsif(  $type eq 'CIRCLE'  ) {
                $self->draw_circle($data);

        } elsif(  $type eq 'BARS' ) {
                $self->draw_bars($data);

        } elsif(  $type eq 'HBARS' ) {
                $self->draw_horizontal_bars( $data );

        } else {
		$self->configure(-type => $autom);
		$self->set($data);
        }
}

#-------------------------------------------------
sub window_size {
#-------------------------------------------------
        my $self = shift || return error("No Objekt!");
	return undef unless(ref $self eq __PACKAGE__);

        my ($width, $height);
        my $conf = $self->{conf};
        $self->update;
	return unless( $self->cget(-fill) );
        unless(defined $conf->{width} && $conf->{width} > 1 && defined $conf->{height} && $conf->{height} > 1) {
                $width  = $self->width;
                $height = $self->height;
        } else {
                $width  = ( $self->cget(-fill) eq 'x' || $self->cget(-fill) eq 'both' ? $self->width : $conf->{width} );
                $height = ( $self->cget(-fill) eq 'y' || $self->cget(-fill) eq 'both' ? $self->height : $conf->{height} );
        }
        $self->debug('Width: %d, Height: %d', $width, $height);
        return ($width, $height);
}

#-------------------------------------------------
sub reference {
#-------------------------------------------------
        my $self = shift || return error("No Objekt!");
	return undef unless(ref $self eq __PACKAGE__);
        my $data = shift;
        my $reference = $self->cget(-reference) || return $data;
        my ($ref_name, $ref_value) = split(/,/, $reference);

        if(ref $data eq 'HASH') {
                my %werte = %$data;
                my $summe;
                foreach (keys %werte) {
                        $summe+=$werte{$_};
                }
                $werte{$ref_name} = $ref_value - $summe;
                return \%werte;
        }
}

#-------------------------------------------------
sub clear {
#-------------------------------------------------
        my $self = shift || return error("No Objekt!");
	return undef unless(ref $self eq __PACKAGE__);
	$self->{data} = undef;
	$self->{look} = undef;
	$self->{colors} = undef;
	$self->redraw;
}

#-------------------------------------------------
sub variable {
#-------------------------------------------------
        use Tie::Watch;
        my ($graph, $vref) = @_;

        $graph->{watch}->Unwatch
                if(defined $graph->{watch}); # Stoppen, falls ein Watch exisitiert

        my $store = [sub {
             my($self, $key, $new_val) = @_;
             $self->Store($key, $new_val);   # Stopft den neuen Wert ins Watch
             my $args = $self->Args(-store); # Nimmt warn Argumente
             $args->[0]->set($args->[1]);    # Ruft warn interne Routine auf
         }, $graph, $vref];

        $graph->{watch} = Tie::Watch->new(
                -variable => $vref,
                -store => $store );

        $graph->set($vref);

        $graph->OnDestroy( [sub {$_[0]->{watch}->Unwatch}, $graph] );
} # end variable

#-------------------------------------------------
sub ReadConfig {
#-------------------------------------------------
        # Liest warn Daten und oder berechnet den Confighash
        my $self = shift || return error("No Objekt!");
	return undef unless(ref $self eq __PACKAGE__);
        my $data = shift || return error("No Data!");
        my $conf;

        # Config
        $self->config($data);

        # Typ der Daten
        $conf->{typ} = ref $data;

        # Display Typ
        $conf->{type} = uc($self->cget(-type));

        # Font
        $conf->{font}   = $self->cget(-font);

	# Standartcolor
	$conf->{fg} 	= $self->cget(-foreground);

	# Headroom
	$conf->{headroom} = ($self->cget(-headroom) / 100) + 1;  

        # Windowsize
        ($conf->{width}, $conf->{height}) = $self->window_size();
	return unless($conf->{width} or $conf->{height});

        $self->{conf}->{width}  = $conf->{width};
        $self->{conf}->{height} = $conf->{height};

        # Padding
        my $padding = $self->cget(-padding);
        $conf->{xpad}           = $padding->[3];
        $conf->{xpad_right}     = $padding->[1];
        $conf->{ypad}           = $padding->[2];
        $conf->{ypad_top}       = $padding->[0];

        $conf->{width}          -= $conf->{xpad_right};
        $conf->{height}         -= $conf->{ypad_top};

        # Title
        $conf->{title}  = $self->cget(-title);
        $conf->{titlecolor} = $self->cget(-titlecolor);

        # Coordinates
        $conf->{y_null} = $conf->{height} - $conf->{ypad};      # 0 Koordinate y-Achse
        $conf->{x_null} = $conf->{xpad};                        # 0 Koordinate x-Achse


        # Werte zählen
        if($conf->{typ} eq 'ARRAY') {
                $conf->{count} = $#$data + 1;
        } elsif($conf->{typ} eq 'HASH' && $self->cget(-look) && $conf->{type} eq 'LINE') {
                $conf->{count} = $self->cget(-look);
        } elsif($conf->{typ} eq 'HASH' && $conf->{type} eq 'LINE') {
		# Durchzählen der Werte
                foreach ( keys %$data ) {
                        $conf->{count} = $#{$data->{$_}}
                        	if($#{$data->{$_}} > $conf->{count});
                }

        } else {
                foreach ( keys %$data ) {
                        next if(ref $data->{$_});
                        $conf->{count}++;
                }
        }
	
	$self->{cfg} = $conf;
        return $conf;
}

#-------------------------------------------------
sub axis {
#-------------------------------------------------
        my $self = shift || return error("No Objekt!");
	return undef unless(ref $self eq __PACKAGE__);
        my $conf = shift || return error("No Config");
        my $werte = shift || return error("No Data");


        goto NOAXIS
                if($conf->{type} eq 'CIRCLE');

	# Labels
	$self->labels();

        # X - K O O R D I N A T E ------------------------------
        $self->createLine(
                $conf->{x_null}, $conf->{y_null},
                $conf->{width}, $conf->{y_null},
                -width => 1,
                -fill => $conf->{fg},
                );


        # X-Ticks
        if($conf->{type} eq 'HBARS' || $conf->{type} eq 'LINE') {
                for(my $i = 0; $i <= $self->cget(-xtick); $i++) {
                        my $x = $conf->{x_null} + (int(($conf->{width} - $conf->{x_null})/$self->cget(-xtick) + 0.99) * $i);

                        $self->createLine(
                                $x, ( $conf->{height} - ($conf->{ypad} + 5) ),
                                $x, $conf->{y_null},
                                -width => 1,
                		-fill => $conf->{fg},
                                );
                        $self->createText(
                                $x, $conf->{y_null},
                                -text => sprintf(' '.$self->cget(-xformat), ( ($conf->{type} eq 'HBARS' ? $conf->{max_value} : $conf->{count}) / $self->cget(-xtick)) * $i),
                                -anchor => 'n',
                                -font => $conf->{font},
                		-fill => $conf->{fg},
                                ) if($i);
                }
        } else {
                my $i = -1;
                foreach my $name ( sort { $self->sorter } keys %$werte) {
                        next if(ref $werte->{$name});
                        $i++;
                        my $text = sprintf($self->cget(-xformat), $name);

                        my $x = ($conf->{x_null} + $self->cget(-barwidth)) + (int(( $conf->{width} - $conf->{x_null} ) / $conf->{count} + 0.99) * $i);

                        $self->createLine(
                                $x, ($conf->{height}-($conf->{ypad}+5)),
                                $x, $conf->{y_null},
                                -width => 1,
                		-fill => $conf->{fg},
                                );
                        $self->createText($x, $conf->{y_null},
                                -text => $text,
                                -anchor => 'n',
                                -font => $conf->{font},
                		-fill => $conf->{fg},
				);
                }
        }
        # X - K O O R D I N A T E ---------BOTTOM----------------


        # Y - K O O R D I N A T E -------------------------------
        $self->createLine(
                $conf->{x_null}, $conf->{y_null},
                $conf->{x_null}, $conf->{ypad_top},
                -width => 1,
                -fill => $conf->{fg},
                );

        if($conf->{type} eq 'HBARS') {
                my $i = 0.5;
                foreach my $name ( sort { $self->sorter } keys %$werte) {

                        my $y = ($conf->{y_null}) - (int(($conf->{y_null} - $conf->{ypad_top}) / $conf->{count} + 0.99) * $i++);

                        $self->createLine(
                                $conf->{x_null},   $y,
                                $conf->{x_null}-5, $y,
                                -width => 1,
                		-fill => $conf->{fg},
                        );

                        $self->createText($conf->{x_null}-8, $y,
                                -text => $name,
                                -anchor => 'e',
                                -font => $conf->{font},
                		-fill => $conf->{fg},
                        );
                }
        } else {
                for (my $i = 0; $i <= $self->cget(-ytick); $i++) {
                        next unless($i);

                        my $y = ($conf->{y_null}) - (int(($conf->{y_null} - $conf->{ypad_top})/$self->cget(-ytick) + 0.99) * $i);
                        $self->createLine(
                                $conf->{x_null},   $y,
                                $conf->{x_null}-5, $y,
                                -width => 1,
                		-fill => $conf->{fg},
			);

                        $self->createText($conf->{x_null}-8, $y,
                                -text => sprintf($self->cget(-yformat), (($conf->{max_value}/$self->cget(-ytick)) * $i)),
                                -anchor => 'e',
                                -font => $conf->{font},
                		-fill => $conf->{fg},
			);
                }
        }
        # Y - K O O R D I N A T E ---------BOTTOM----------------

        NOAXIS:

        # Titel
        $self->createText(
                ($conf->{width} / 2), $self->cget(-lineheight),
                -text => $conf->{title},
                -justify => 'center',
                -fill => $conf->{titlecolor},
                ) if($conf->{title});
}

#-------------------------------------------------
sub maxmin {
#-------------------------------------------------
        my $self = shift || return error("No Objekt!");
	return undef unless(ref $self eq __PACKAGE__);
        my $conf = shift || return error("No Config");
        my $werte = shift || return error("No Data");
        my $MAX;

        if($conf->{typ} eq 'HASH' && $conf->{type} eq 'LINE')
        {
                $MAX->{$conf->{title}}->{min} = 10000   unless $MAX->{$conf->{title}}->{min};
                $MAX->{$conf->{title}}->{max} = 0       unless $MAX->{$conf->{title}}->{max};
		my $data = ($self->cget(-look) ? $self->{look} : $werte); 
                foreach my $name (keys %{$data}) {
                        foreach my $value (@{$data->{$name}}) {
                                $MAX->{$conf->{title}}->{max} = $value if( $MAX->{$conf->{title}}->{max} <= $value );
                                $MAX->{$conf->{title}}->{min} = $value if( $MAX->{$conf->{title}}->{min} >= $value );
                                $MAX->{$conf->{title}}->{avg} =
                                        ( $MAX->{$conf->{title}}->{max} - $MAX->{$conf->{title}}->{min} ) / 2 +
                                                $MAX->{$conf->{title}}->{min};
                        }
                }
                $conf->{max_value} = $self->cget(-max)
                        ? $self->cget(-max)
                        : $MAX->{$conf->{title}}->{max} * $conf->{headroom};
        }
        elsif($conf->{typ} eq 'ARRAY')
        {
                $MAX->{$conf->{title}}->{min} = 10000   unless $MAX->{$conf->{title}}->{min};
                $MAX->{$conf->{title}}->{max} = 0       unless $MAX->{$conf->{title}}->{max};
                foreach my $value (@{$werte}) {
                        $MAX->{$conf->{title}}->{max} = $value if( $MAX->{$conf->{title}}->{max} <= $value );
                        $MAX->{$conf->{title}}->{min} = $value if( $MAX->{$conf->{title}}->{min} >= $value );
                        $MAX->{$conf->{title}}->{avg} =
                                ( $MAX->{$conf->{title}}->{max} - $MAX->{$conf->{title}}->{min} ) / 2 +
                                        $MAX->{$conf->{title}}->{min};
                }
                $conf->{max_value} = $self->cget(-max)
                        ? $self->cget(-max)
                        : $MAX->{$conf->{title}}->{max} * $conf->{headroom};
        }
        elsif ($conf->{typ} eq 'HASH')
        {
                $MAX->{$conf->{title}}->{min} = 10000   unless $MAX->{$conf->{title}}->{min};
                $MAX->{$conf->{title}}->{max} = 0       unless $MAX->{$conf->{title}}->{max};

                foreach my $name (keys %{$werte}) {
                        next if ref $werte->{$name};
                        my $value = $werte->{$name};
                        $MAX->{$conf->{title}}->{max} = $value if( $MAX->{$conf->{title}}->{max} <= $value );
                        $MAX->{$conf->{title}}->{min} = $value if( $MAX->{$conf->{title}}->{min} >= $value );
                        $MAX->{$conf->{title}}->{avg} =
                                ( $MAX->{$conf->{title}}->{max} - $MAX->{$conf->{title}}->{min} ) / 2 +
                                        $MAX->{$conf->{title}}->{min};
                }
                $conf->{max_value} = $self->cget(-max)
                        ? $self->cget(-max)
                        : $MAX->{$conf->{title}}->{max} * $conf->{headroom};
        }

	$conf->{max_value} = 1 unless($conf->{max_value});

	# Rons Idea             
	# Y
	my $val = sprintf($self->cget(-yformat), $conf->{max_value});	
	if($val == int($val) && $self->cget(-ytick) > $val) {
		$self->configure(-ytick => int($val) + ($conf->{max_value} > $val ? 1 : 0));
        	$conf->{max_value} =  int($conf->{max_value} + 0.99999); 
	}
	# X
	$val = sprintf($self->cget(-xformat), $conf->{max_value});	
	if($val == int($val) && $self->cget(-xtick) > $val) {
		$self->configure(-xtick => int($val) + ($conf->{max_value} > $val ? 1 : 0));
        	$conf->{max_value} =  int($conf->{max_value} + 0.99999); 
	}
	# --

        # MAX-MIN Linien
        if($self->cget(-maxmin) && $conf->{max_value} && ! $conf->{type} eq 'CIRCLE') {
                my $xa = $conf->{x_null};
                my $xe = $conf->{width}+10;
                my $y = $conf->{y_null} - int((($conf->{y_null})/$conf->{max_value}) * $MAX->{$conf->{title}}->{min});

                if($conf->{type} !~ /BARS/) {
                        $self->createLine($xa, $y, $xe, $y,
                                -width => 1,
                                -fill  => 'gray65');    # MIN-Linie

                        $self->createText($xe-20, $y,
                                -text => sprintf($self->cget(-printvalue) || '%g', $MAX->{$conf->{title}}->{min}),
                                -anchor => 'se',
                                -font => $conf->{font},
                                -fill => 'gray65');


                        $y = $conf->{y_null} - int((($conf->{y_null})/$conf->{max_value}) * $MAX->{$conf->{title}}->{avg});
                        $self->createLine($xa, $y, $xe, $y,
                                -width => 1,
                                -fill  => 'gray65');    # AVG-Linie

                        $self->createText($xe-20, $y,
                                -text => sprintf($self->cget(-printvalue) || '%g', $MAX->{$conf->{title}}->{avg}),
                                -anchor => 'se',
                                -font => $conf->{font},
                                -fill => 'gray65');



                        $y = $conf->{y_null} - int((($conf->{y_null})/$conf->{max_value}) * $MAX->{$conf->{title}}->{max}),
                        $self->createLine($xa, $y, $xe, $y,
                                -width => 1,
                                -fill  => 'gray65');    # AVG-Linie

                        $self->createText($xe-20, $y,
                                -text => sprintf($self->cget(-printvalue) || '%g', $MAX->{$conf->{title}}->{max}),
                                -anchor => 'se',
                                -font => $conf->{font},
                                -fill => 'gray65');
                }
        }
        # --

}


#-------------------------------------------------
sub draw_circle {
#-------------------------------------------------
        # Plot LineStats
        my $self = shift || return error("No Objekt!");
	return undef unless(ref $self eq __PACKAGE__);
        my $data = shift || return error("No Data!");

	# Check
	return warn("Your data is incorrect, i need a Hashreference!")
		unless(ref $data eq 'HASH');


        my $werte = $self->reference($data);
        my $conf = $self->ReadConfig($werte) || return;

        $self->delete('all');

        # MaxMin Werte ermitteln und ggf Linien zeichnen
        $self->maxmin($conf, $werte);

        # Axis (Titel ... usw
        $self->axis($conf, $werte);

        # Sizes
        my $width = ($self->cget(-legend) ? $conf->{height} : $conf->{width});
        my $height = $conf->{y_null};

        # Shadow
        $self->createOval(
                        ($conf->{x_null} + $self->cget(-shadowdeep) ), ($conf->{ypad_top} + $self->cget(-shadowdeep)),
                        ($width + $self->cget(-shadowdeep)), ($height + $self->cget(-shadowdeep)),
                -fill => $self->cget(-shadow),
                -outline => $self->cget(-shadow),
                -width => 0,
                ) if($self->cget(-shadowdeep));         # Schatten

        # Segments
        my ($summe, $start, $count, $grad, $x, $y);
        foreach ( keys %$werte ) { $summe+=$werte->{$_} };
        $start = 0;
        $count = 0;

        foreach my $name (sort { $self->sorter } keys %$werte ) {
                my $col = $self->{colors}->{$name};
                next unless $werte->{$name};
                $grad = (360/$summe) * $werte->{$name};
                $grad = 359.99 if($grad == 360);

                $self->{elements}->{$name} = $self->createArc(
                                $conf->{x_null}, $conf->{ypad_top},
                                $width, $height,
                        -width => $self->cget(-linewidth),
                        -fill => $col,
                        -start => $start,
                        -extent => $grad,
                        );

                $start+=$grad;
        }

        # balloon
        $self->balloon($self->{elements}, $werte);

	# Legend
	$self->legend($werte);
}

#-------------------------------------------------
sub labels {
#-------------------------------------------------
        my $self = shift || return error("No Objekt!");
	return undef unless(ref $self eq __PACKAGE__);
	my $conf = $self->{cfg};

	# X-Achse --------------------------------
	if($self->cget(-xlabel)) {
		$self->createLine(
			$conf->{width} - ($conf->{width} / 10), 	$conf->{y_null} - 10,
			$conf->{width} - 5, 				$conf->{y_null} - 10,
			-arrow	=> 'last',
			-fill	=> $conf->{fg},
		);
	
	        $self->createText(
	        	$conf->{width} - ($conf->{width} / 10) - 5, $conf->{y_null} - 10,
		                -text => $self->cget(-xlabel),
				-font => $conf->{font},
				-fill	=> $conf->{fg},
		                -anchor => 'e',
	                );
	}
	# ---------------------------------------

	# Y-Achse --------------------------------
	if($self->cget(-ylabel)) {
		$self->createLine(
			$conf->{x_null} + 10, $conf->{ypad_top} - 5,
			$conf->{x_null} + 10, $conf->{ypad_top} + ($conf->{height} / 10),
			-arrow	=> 'first',
			-fill	=> $conf->{fg},
		);

	        $self->createText(
			$conf->{x_null} + 15, $conf->{ypad_top} + ($conf->{height} / 10),
		                -text => $self->cget(-ylabel),
				-font => $conf->{font},
		                -anchor => 'w',
				-fill	=> $conf->{fg},
	                );
	}
	# ---------------------------------------
	
}


#-------------------------------------------------
sub legend {
#-------------------------------------------------
        my $self = shift || return error("No Objekt!");
	return undef unless(ref $self eq __PACKAGE__);
	my $data = shift || return error("No Data!");
	my $conf = $self->{cfg};
	return unless($self->cget(-legend));	

        my $c = 0;
	my $fw = $self->cget(-lineheight) || 15; 

	foreach my $name (sort { $self->sorter } keys %$data) {
	        my $x = $conf->{width};
	        my $y = $fw + ( $fw * $c );     # XXX
	
	        my $thick = $self->cget(-dots) || 5;
	
	        $self->createRectangle($x, $y,
	                $x-$thick, $y-$thick,
	                -fill => $self->{colors}->{$name},
	                -width => $self->cget(-linewidth),
	                );
	
	        $self->createText($x - ($thick*2), $y,
	                -text => sprintf( $self->cget(-printvalue) || '%s: %s', $name, (ref $data->{$name} ? '' : $data->{$name}) ),
			-font	=> $conf->{font},
	                -anchor => 'e',
			-fill	=> $conf->{fg},
	                );
		$c++
	}	
}


#-------------------------------------------------
sub readData {
#-------------------------------------------------
        my $self = shift || return error("No Objekt!");
	return undef unless(ref $self eq __PACKAGE__);
        my $c = $self->configure;
        my $config;
        foreach my $n ($c) {
                $config->{$n->[0]} = $n->[3];
        }
}


#-------------------------------------------------
sub wire {
#-------------------------------------------------
        my $self = shift || return error("No Objekt!");
	return undef unless(ref $self eq __PACKAGE__);
        my $conf = shift || warn "No Conf";

	return unless( $self->cget(-wire) );

        # X-Achse
        my $xtick = ( $conf->{typ} eq 'HASH' && $conf->{type} ne 'HBARS' ? $conf->{count} : $self->cget(-xtick) );
	   $xtick = 1 unless $xtick;

        if($conf->{type} eq 'HBARS' || $conf->{type} eq 'LINE') {
	        for(my $i = 0; $i <= $xtick; $i++) {
	                my $x = $conf->{x_null} + (int(($conf->{width} - $conf->{x_null})/$self->cget(-xtick) + 0.99) * $i);
	
	                $self->createLine( $x, $conf->{y_null}, $x, $conf->{ypad_top},
	                    -width => 1,
	                    -fill  => $self->cget(-wire)
	                  );
	        }
	} else {
	        for(my $i = 0; $i <= $xtick; $i++) {
                        my $x = ($conf->{x_null} + $self->cget(-barwidth)) + (int(( $conf->{width} - $conf->{x_null} ) / $conf->{count} + 0.99) * $i);
	
	                $self->createLine( $x, $conf->{y_null}, $x, $conf->{ypad_top},
	                    -width => 1,
	                    -fill  => $self->cget(-wire)
	                  );
	        }
	}


        # Y-Achse
        my $ytick = ($conf->{type} eq 'HBARS' ? $conf->{count} : $self->cget(-ytick));
   	   $ytick = 1 unless $ytick;

        for (my $i = 0; $i <= $ytick; $i++) {
                my $y = ($conf->{y_null}) - (int( ( $conf->{y_null} - $conf->{ypad_top} )/$ytick + 0.99) * $i);
                $self->createLine( $conf->{x_null}, $y, $conf->{width}, $y,
                    -width => 1,
                    -fill  => $self->cget(-wire),
                  );
        }
}

#-------------------------------------------------
sub config {
#-------------------------------------------------
        my $self = shift || return error("No Objekt!");
	return undef unless(ref $self eq __PACKAGE__);
        my $data = shift || return;
        my $cols = $self->cget(-colors);
        my @colors = split(/,/, $cols);
        my $config = $self->cget(-config);
        my $c = -1;

        foreach my $name( keys %$data) {
                next if(defined $self->{colors}->{$name} && ! defined $config->{$name});
                $c++;
                $c = -1 unless($colors[$c]);

                # Colors
                $self->{colors}->{$name} = $config->{$name}->{'-color'} || $colors[$c];

                # title
                if($config->{$name}->{'-title'}) {
                        $data->{$config->{$name}->{'-title'}} = delete $data->{$name};
                        $self->{data} = $data;
                }
        }
}

#-------------------------------------------------
sub look {
#-------------------------------------------------
        my $self = shift || return error("No Objekt!");
	return undef unless(ref $self eq __PACKAGE__);
        my $data = shift || $self->{data} || return;
        return unless($self->cget(-look));

        foreach my $name (keys %$data) {
                push(@{$self->{look}->{$name}}, $data->{$name});
                splice(@{$self->{look}->{$name}}, 0, ($#{$self->{look}->{$name}} - $self->cget(-look)))
                        if($#{$self->{look}->{$name}} >= $self->cget(-look));
        }
}

#-------------------------------------------------
sub sorter {
#-------------------------------------------------
	my $self = shift || return error("No Objekt!");
	return undef unless(ref $self eq __PACKAGE__);
        my $typ = shift || $self->cget(-sortnames);

	if($self->cget(-sortreverse)) {
	        if($typ eq 'num') {
	                $b <=> $a
	        } else {
	                $b cmp $a
	        }
	} else {
	        if($typ eq 'num') {
	                $a <=> $b
	        } else {
	                $a cmp $b
	        }
	}
	
}

#-------------------------------------------------
sub balloon{
#-------------------------------------------------
        my $self = shift || return error("No Objekt!");
	return undef unless(ref $self eq __PACKAGE__);
	my $elements = shift || return error('No Grfxobjects');
	my $werte = shift || return error('No Values');
	my $bh;
	
	foreach my $name (keys %$werte) {
		$bh->{$elements->{$name}} = sprintf($self->cget(-printvalue) || ($name && $werte ? '%s: %g' : '%g'), $name, $werte->{$name})
			if($werte->{$name});
	}

        $self->{balloon}->attach(
                $self, 
		-balloonposition => 'mouse',
		-msg => $bh,
        ) if(defined $self->{balloon});
}

#-------------------------------------------------
sub error {
#-------------------------------------------------
	my $msg = shift || return undef;
	warn $msg;
	return undef;
}

#-------------------------------------------------
sub debug {
#-------------------------------------------------
        my $self = shift || return error("No Objekt!");
	return undef unless(ref $self eq __PACKAGE__);
        my $msg  = shift || return;
        return unless($self->cget(-debug));
        printf($msg, @_);
        print "\n";
}


1;

=head1 AUTHOR

Frank Herrmann
xpix@xpix.de
http://www.xpix.de

=head1 SEE ALSO

Tk,
Tk::Trace,
Tk::Canvas,

=cut

__END__


