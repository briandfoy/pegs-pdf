package PeGS::PDF;
use strict;

use warnings;
no warnings;

use subs qw();
use vars qw($VERSION);

$VERSION = '0.10_01';

=head1 NAME

PeGS::PDF - XXX: This is the description

=head1 SYNOPSIS

	use PeGS::PDF;

=head1 DESCRIPTION

=over 4

=cut



BEGIN {

package PeGS::PDF;
use base qw(PDF::EasyPDF);
use strict;
use warnings;

use List::Util qw(max);

sub padding_factor { 0.7 }
sub font_height    { 10 }
sub font_width     { 10 }
sub font_size      { 10 }
sub connector_height { 10 }
sub black_bar_height { 5 }
sub stroke_width     { 0.5 }
sub pointy_width     { ( $_[0]->font_height + 2 * $_[0]->y_padding ) / 2 * sqrt(2) }
sub box_height       { $_[0]->font_height + 2 * $_[0]->y_padding };

sub y_padding { $_[0]->padding_factor * $_[0]->font_height }
sub x_padding { $_[0]->padding_factor * $_[0]->font_width  }

sub make_reference
	{
	my( $pdf, $name, $value, $bottom_left_x, $bottom_left_y ) = @_;

	my $scalar_width = 10 * length $name;
	
	$pdf->make_pointy_box( 
		$bottom_left_x, 
		$bottom_left_y, 
		$scalar_width + 2* $pdf->x_padding,
		$pdf->box_height, 
		$name
		);
		
	$pdf->lines(
		( $bottom_left_x + $pdf->x_padding + $scalar_width / 2 ), $bottom_left_y,
		( $bottom_left_x + $pdf->x_padding + $scalar_width / 2 ), $bottom_left_y - 10,
		);
		

	$pdf->make_text_box(
		$bottom_left_x, 
		$bottom_left_y - 10 - $pdf->font_height - 2 * $pdf->y_padding,
		$scalar_width  + 2 * $pdf->x_padding,
		$pdf->box_height, 		
		''
		);
		
	my $angle  = 90;
	my $length = 85;
	
	$pdf->make_reference_arrow(
		$bottom_left_x + ( $scalar_width + 2 * $pdf->x_padding ) / 2,
		$bottom_left_y + $pdf->box_height / 2 - $pdf->connector_height - $pdf->box_height - 2*$pdf->stroke_width,
		$angle,
		$length,
		);
		
	$pdf->make_reference_icon(
		$bottom_left_x + ( $scalar_width + 2 * $pdf->x_padding ) / 2,
		$bottom_left_y + $pdf->box_height / 2 - $pdf->connector_height - $pdf->box_height,
		);
	
	my $x = $length + $bottom_left_x + ( $scalar_width + 2 * $pdf->x_padding ) / 2;
	
	if( ref $value eq ref \ '' )  { }
	elsif( ref $value eq ref [] ) { }
	elsif( ref $value eq ref {} ) { }
	
	}

sub make_circle
	{
	my( $pdf, 
		$xc, # x at the center of the circle
		$yc, # y at the center of the circle
		$r   # radius
		) = @_;

	$pdf->lines( $xc, $yc + 30, $xc, $yc - 30 );
	$pdf->lines( $xc - 30, $yc, $xc + 30, $yc );
	
	my $points = 5;
	my $Pi = 3.1415926;
	
	my $arc = 2 * $Pi / $points;

	my $darc = $arc * 360 / ( 2 * $Pi ); 
=pod 

	my @points = map 
		[ $xc + $r * cos( $arc * $_ / 2 ), $yc + $r * sin( $arc * $_ / 2 ) ],
		0 .. $points - 1;

=cut

	my @points = (
		[ $r * cos(       $arc / 2 ),   $r * sin(       $arc / 2 ) ],
		[ $r * cos( -     $arc / 2 ),   $r * sin( -     $arc / 2 ) ],
		);
	
	$pdf->{stream} .= "@{$points[0]} m\n";
	
	foreach my $i ( 0 .. $points - 1 )
		{
		my( @xp, @yp );
		
		( $xp[0], $yp[0], $xp[3], $yp[3] ) = ( @{ $points[0] }, @{ $points[1] } );
				
		( $xp[1], $yp[1] ) = ( (4 * $r - $xp[0])/3, (1-$xp[0])*(3-$xp[0])/(3*$yp[0]) );

		( $xp[2], $yp[2] ) = ( $xp[1], -$yp[1] );

		# rotate and translate
		my @x = map { $_ + $xc } map {   $xp[$_] * cos( $arc * $i ) + $yp[$_] * sin( $arc * $i ) } 0 .. $#xp;
		my @y = map { $_ + $yc } map { - $xp[$_] * sin( $arc * $i ) + $yp[$_] * cos( $arc * $i ) } 0 .. $#yp;		
		
		$pdf->{stream} .= "$x[0] $y[0] m\n$x[1] $y[1] $x[2] $y[2] $x[3] $y[3] c\nf\n";
				
		#$pdf->lines( $x0, $y0, $x1, $y1 );
		#$pdf->lines( $x1, $y1, $x1, $y1 + 10 );
		#$pdf->lines( $x3, $y3, $x2, $y2 );
		#$pdf->lines( $x2, $y2, $x2, $y2 - 10 );
		}

	}

=pod

$c .= sprintf(' %.2f %.2f %.2f %.2f %.2f %.2f c', 
                  $x + $b, $y, 
                  $x + $r, $y - $r + $b, 
                  $x + $r, $y - $r); 
    /* Set x/y to the final point. */ 
    $x = $x + $r; 
    $y = $y - $r; 
    /* Third circle quarter. */ 
    $c .= sprintf(' %.2f %.2f %.2f %.2f %.2f %.2f c', 
                  $x, $y - $b, 
                  $x - $r + $b, $y - $r, 
                  $x - $r, $y - $r); 
    /* Set x/y to the final point. */ 
    $x = $x - $r; 
    $y = $y - $r; 
    /* Fourth circle quarter. */ 
    $c .= sprintf(' %.2f %.2f %.2f %.2f %.2f %.2f c %s', 
                  $x - $b, $y, 
                  $x - $r, $y + $r - $b, 
                  $x - $r, $y + $r, 
                  $op); 
=cut

sub make_magic_circle
	{
	my( $pdf, 
		$xc, # x at the center of the circle
		$yc, # y at the center of the circle
		$r   # radius
		) = @_;

	my $magic = $r * 0.552;
	my( $x0p, $y0p ) = ( $xc - $r, $yc );
	$pdf->{stream} .= "$x0p $y0p m\n";
	
	{
	( $x0p, $y0p ) = ( $xc - $r, $yc );
	my( $x1, $y1 ) = ( $x0p,               $y0p + $magic );
	my( $x2, $y2 ) = ( $x0p + $r - $magic, $y0p + $r     );
	my( $x3, $y3 ) = ( $x0p + $r,          $y0p + $r     );
	$pdf->{stream} .= "$x1 $y1 $x2 $y2 $x3 $y3 c\n";
	}
	
	{
	( $x0p, $y0p ) = ( $xc, $yc + $r );
	my( $x1, $y1 ) = ( $x0p + $magic, $y0p               );
	my( $x2, $y2 ) = ( $x0p + $r,     $y0p - $r + $magic );
	my( $x3, $y3 ) = ( $x0p + $r,     $y0p - $r          );
	$pdf->{stream} .= "$x1 $y1 $x2 $y2 $x3 $y3 c\n";
	}
	
	{
	( $x0p, $y0p ) = ( $xc + $r, $yc );
	my( $x1, $y1 ) = ( $x0p,               $y0p - $magic );
	my( $x2, $y2 ) = ( $x0p - $r + $magic, $y0p - $r     );
	my( $x3, $y3 ) = ( $x0p - $r,          $y0p - $r     );
	$pdf->{stream} .= "$x1 $y1 $x2 $y2 $x3 $y3 c\n";
	}
	
	{
	( $x0p, $y0p ) = ( $xc, $yc - $r );
	my( $x1, $y1 ) = ( $x0p - $magic,               $y0p );
	my( $x2, $y2 ) = ( $x0p - $r, $y0p + $r - $magic    );
	my( $x3, $y3 ) = ( $x0p - $r,          $y0p + $r     );
	$pdf->{stream} .= "$x1 $y1 $x2 $y2 $x3 $y3 c\n";
	
	}
	
	$pdf->{stream} .= "f\n";
	}
	
sub make_regular_polygon
	{
	my( $pdf, 
		$xc, # x at the center of the circle
		$yc, # y at the center of the circle
		$points,
		$r   # radius,
		) = @_;
	
	my $arc = 2 * 3.1415926 / $points;
		
	my @points = map 
		[ $xc + $r * cos( $arc * $_ ), $yc + $r * sin( $arc * $_ ) ],
		0 .. $points - 1;
		
		
	foreach my $i ( 0 .. $#points )
		{
		$pdf->lines(
			@{ $points[$i]   },
			@{ $points[$i-1] },
			);
		}

	}
	
sub make_reference_arrow
	{
	my( $pdf, $start_x, $start_y, $angle, $length ) = @_;
		
	my $end_x = $start_x + $length * sin( $angle * 2 * 3.14 / 360 );
	my $end_y = $start_y + $length * cos( $angle * 2 * 3.14 / 360 );

	my $end_xp = $start_x + ($length-2) * sin( $angle * 2 * 3.14 / 360 );
	my $end_yp = $start_y + ($length-2) * cos( $angle * 2 * 3.14 / 360 );
	
	my $L = 8;
	my $l = 8;
	
	my $beta = 10;

	my $arrow_tip1_x = $end_x - $L*sin( $angle * 2 * 3.14 / 360 ) - $l * cos( $angle * 2 * 3.14 / 360 ) / 2;
	my $arrow_tip2_x = $end_x - $L*sin( $angle * 2 * 3.14 / 360 ) + $l * cos( $angle * 2 * 3.14 / 360 ) / 2;
	
	my $arrow_tip1_y = $end_y - $L*cos( $angle * 2 * 3.14 / 360 ) + $l * sin( $angle * 2 * 3.14 / 360 ) / 2;
	my $arrow_tip2_y = $end_y - $L*cos( $angle * 2 * 3.14 / 360 ) - $l * sin( $angle * 2 * 3.14 / 360 ) / 2;
	
	$pdf->lines( $start_x, $start_y, $end_xp, $end_yp );

=pod

	$pdf->lines( $end_x, $end_y, $arrow_tip1_x, $arrow_tip1_y );
	$pdf->lines( $end_x, $end_y, $arrow_tip2_x, $arrow_tip2_y );

	$pdf->lines( $arrow_tip1_x + $pdf->stroke_width, $arrow_tip1_y, $arrow_tip2_x + $pdf->stroke_width, $arrow_tip2_y );

=cut

 	$pdf->filledPolygon(
 		$end_x, $end_y,
 		$arrow_tip1_x, $arrow_tip1_y,
 		$arrow_tip2_x, $arrow_tip2_y,
 		);
  
	}

sub make_reference_icon
	{
	my( $pdf, $x, $y ) = @_;

	my $radius = $pdf->box_height / 6;
	
	$pdf->make_magic_circle(
		$x - $radius / 4, 
		$y - $radius / 4,
		$radius, 
		);
	
	}
	
=for comment

http://www.adobe.com/devnet/acrobat/pdfs/PDF32000_2008.pdf

sub make_circle
	{
	my( $pdf, $x, $y, $radius, $start_angle, $end_angle ) = @_;
	
	# theta is sweep, which is 360
	
	my $Pi2 = 3.1415926 * 2;
	
	my( $x0, $y0 ) = ( cos( 180 / $Pi2 ), sin( 180 / $Pi2 ) );
	my( $x1, $y1 ) = ( (4 - $x0) / 3, (1-$x0)*(3-$x0)/(3*$y0) )
	my( $x2, $y2 ) = ( $x1, -$y0 );
	my( $x3, $y3 ) = ( $x1, -$y1 );
	
	$pdf->{stream} .= <<"PDF";
$x $y m
$x1 $y1 $x2 $y2 $x3 $y3 c
	
	
PDF
	
	
	}

=cut

sub make_scalar
	{
	my( $pdf, $name, $value, $bottom_left_x, $bottom_left_y ) = @_;
	
	my $length = max( map { length $_ } $name, $$value );

	my $scalar_width  = 10*$length;
	my $scalar_height = 10;
	
	$pdf->make_pointy_box( 
		$bottom_left_x, 
		$bottom_left_y, 
		$scalar_width + 2* $pdf->x_padding,
		$pdf->box_height, 
		$name
		);
		
	$pdf->lines(
		( $bottom_left_x + $pdf->x_padding + $scalar_width / 2 ), $bottom_left_y,
		( $bottom_left_x + $pdf->x_padding + $scalar_width / 2 ), $bottom_left_y - 10,
		);
		

	$pdf->make_text_box(
		$bottom_left_x, 
		$bottom_left_y - 10 - $pdf->font_height - 2 * $pdf->y_padding,
		$scalar_width  + 2 * $pdf->x_padding,
		$pdf->box_height, 		
		$value
		);
	}

sub make_array
	{
	my( $pdf, $name, $array, $bottom_left_x, $bottom_left_y ) = @_;
	
	my $length = max( map { length $_ } $name, grep { ! ref $_ } @$array );

	my $scalar_width  = 10*$length;
		
	$pdf->make_pointy_box( 
		$bottom_left_x, 
		$bottom_left_y, 
		$scalar_width +  2 * $pdf->x_padding,
		$pdf->box_height, 
		$name
		);
		
	$pdf->lines(
		( $bottom_left_x + $pdf->x_padding + $scalar_width / 2 ), $bottom_left_y,
		( $bottom_left_x + $pdf->x_padding + $scalar_width / 2 ), $bottom_left_y - $pdf->connector_height,
		);
		
	$pdf->make_collection_bar(
		$bottom_left_x,
		$bottom_left_y - $pdf->connector_height - $pdf->black_bar_height,
		$scalar_width + 2 * $pdf->x_padding + $pdf->pointy_width,
		);
		
	my $count = 0;
	foreach my $value ( @$array )
		{
		$count++;
		$pdf->make_text_box(
			$bottom_left_x, 
			$bottom_left_y - $pdf->connector_height - $pdf->black_bar_height - $count*($pdf->font_height + 2 * $pdf->y_padding),
			$scalar_width  + 2 * $pdf->x_padding,
			$pdf->box_height, 		
			\ $value
			);
		}
	}
	
sub make_hash
	{
	my( $pdf, $name, $hash, $bottom_left_x, $bottom_left_y ) = @_;
	
	my $key_length   = max( map { length $_ } keys %$hash );
	my $value_length = max( map { length $_ } grep { ! ref $_ } values %$hash );

	my $scalar_width  = 10 * ( $key_length + $value_length ) + 4 * $pdf->x_padding + $pdf->pointy_width;
		
	$pdf->make_pointy_box( 
		$bottom_left_x, 
		$bottom_left_y, 
		$scalar_width,
		$pdf->box_height, 
		$name
		);
		
	$pdf->lines(
		( $bottom_left_x + $pdf->x_padding + $scalar_width / 2 ), $bottom_left_y,
		( $bottom_left_x + $pdf->x_padding + $scalar_width / 2 ), $bottom_left_y - $pdf->connector_height,
		);
		
	$pdf->make_collection_bar(
		$bottom_left_x,
		$bottom_left_y - $pdf->connector_height - $pdf->black_bar_height,
		$scalar_width + $pdf->pointy_width,
		);
		
	my $count = 0;
	foreach my $key ( keys %$hash )
		{
		$count++;
		
		my $key_box_width = 
			10 * $key_length + 1 * $pdf->x_padding + $pdf->pointy_width / 2;
			
			; # share name box extra
		
		$pdf->make_pointy_box(
			$bottom_left_x, 
			$bottom_left_y - $pdf->connector_height - $pdf->black_bar_height - $count*($pdf->font_height + 2 * $pdf->y_padding),
			$key_box_width,
			$pdf->box_height, 		
			$key
			);

		$pdf->make_text_box(
			$bottom_left_x + $key_box_width + $pdf->pointy_width + 2 * $pdf->stroke_width, 
			$bottom_left_y - $pdf->connector_height - $pdf->black_bar_height - $count*($pdf->font_height + 2 * $pdf->y_padding),
			10 * $value_length + $pdf->pointy_width / 2 - $pdf->stroke_width  + $pdf->x_padding / 2,
			$pdf->box_height, 		
			\ $hash->{$key}
			);
		}
	}
	
sub make_collection_bar
	{
	my( $pdf, $bottom_left_x, $bottom_left_y, $width, $text ) = @_;

	my $height = $pdf->black_bar_height;
	
	$pdf->filledRectangle(
		$bottom_left_x - $pdf->stroke_width, 
		$bottom_left_y,
		$width + 2 * $pdf->stroke_width, 
		$height,
		);

	$pdf->strokePath;
	}
	
sub make_text_box
	{
	my( $pdf, $bottom_left_x, $bottom_left_y, $width, $height, $text ) = @_;
		
	$pdf->rectangle(
		$bottom_left_x, 
		$bottom_left_y,
		$width + $height/2 * sqrt(2), 
		$height,
		);

	$pdf->text( 
		$bottom_left_x + $pdf->x_padding, 
		$bottom_left_y + $pdf->y_padding, 
		ref $text ? $$text : $text
		);
	
	}
	
sub make_pointy_box
	{
	my( $pdf, $bottom_left_x, $bottom_left_y, $width, $height, $text ) = @_;
	
	my $point_y = $bottom_left_y + $height / 2;
	my $point_x = $bottom_left_x + $width + $height/2 * sqrt(2);
	
	my @vertices = ( 
		$bottom_left_x,          $bottom_left_y,
		$bottom_left_x + $width, $bottom_left_y,
		$point_x,             $point_y,
		$bottom_left_x + $width, $bottom_left_y + $height,
		$bottom_left_x         , $bottom_left_y + $height
		);

	$pdf->polygon( @vertices );
	
	$pdf->text( 
		$bottom_left_x + $pdf->x_padding, 
		$bottom_left_y + $pdf->y_padding, 
		$text
		);

	}
}


=back

=head1 TO DO


=head1 SEE ALSO


=head1 SOURCE AVAILABILITY

This source is in Github:

	http://github.com/briandfoy/pegs-pdf/

=head1 AUTHOR

brian d foy, C<< <bdfoy@cpan.org> >>

=head1 COPYRIGHT AND LICENSE


Copyright (c) 2009, brian d foy, All Rights Reserved.

You may redistribute this under the same terms as Perl itself.

=cut

1;
