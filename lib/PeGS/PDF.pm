package PeGS::PDF;
use strict;

use warnings;
no warnings;

use subs qw();
use vars qw($VERSION);

$VERSION = '0.10_02';

=encoding utf8

=head1 NAME

PeGS::PDF - Draw simple Perl Graphical Structures

=head1 SYNOPSIS

	use PeGS::PDF;

=head1 DESCRIPTION

=over 4

=cut

use base qw(PDF::EasyPDF);

use List::Util qw(max);

sub padding_factor   { 0.7 }
sub font_height      { 10 }
sub font_width       { 6 }
sub font_size        { 10 }
sub connector_height { 10 }
sub black_bar_height { 5 }
sub stroke_width     { 0.5 }
sub pointy_width     { ( $_[0]->font_height + 2 * $_[0]->y_padding ) / 2 * sqrt(2) }
sub box_height       { $_[0]->font_height + 2 * $_[0]->y_padding }

sub y_padding { $_[0]->padding_factor * $_[0]->font_height }
sub x_padding { $_[0]->padding_factor * $_[0]->font_width  }

sub make_reference {
	my( $pdf, $name, $value, $bottom_left_x, $bottom_left_y ) = @_;

	my $scalar_width = $pdf->font_width * length $name;

	$pdf->make_pointy_box(
		$bottom_left_x,
		$bottom_left_y,
		$scalar_width + 2 * $pdf->x_padding,
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

	my $arrow_start = XYPoint->new(
		$bottom_left_x + ( $scalar_width + 2 * $pdf->x_padding ) / 2,
		$bottom_left_y + $pdf->box_height / 2 - $pdf->connector_height - $pdf->box_height - 2*$pdf->stroke_width,
		);

	my $arrow_end = $pdf->make_reference_arrow(
		$arrow_start,
		$pdf->arrow_angle,
		$pdf->arrow_length($scalar_width),
		);

	$pdf->make_reference_icon(
		#$bottom_left_x + ( $scalar_width + 2 * $pdf->x_padding ) / 2,
		#$bottom_left_y + $pdf->box_height / 2 - $pdf->connector_height - $pdf->box_height,
		$arrow_start
		);

	my $x = $pdf->arrow_length( $scalar_width ) + $bottom_left_x + ( $scalar_width + 2 * $pdf->x_padding ) / 2;

	if(    ref $value eq ref \ '' ) {

		}
	elsif( ref $value eq ref [] ) {
		$pdf->make_list(
			$value,
			$arrow_end->x,
			$arrow_end->y - $pdf->black_bar_height / 2,
			);

		}
	elsif( ref $value eq ref {} ) {
		$pdf->make_anonymous_hash(
			$value,
			$arrow_end->x,
			$arrow_end->y - $pdf->black_bar_height / 2,
			);

		}

	}

sub make_circle {
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

	foreach my $i ( 0 .. $points - 1 ) {
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

sub make_magic_circle {
	my( $pdf,
		$center,
		$r   # radius
		) = @_;

	my( $xc, $yc ) = $center->xy;

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

sub make_regular_polygon {
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


	foreach my $i ( 0 .. $#points ) {
		$pdf->lines(
			@{ $points[$i]   },
			@{ $points[$i-1] },
			);
		}

	}

sub arrow_factor { 15 }

sub arrow_length {
	my( $pdf, $base ) = @_;

	if( defined $base ) { $base + $pdf->arrow_factor; }
	else { 85 }

	}


sub arrow_angle  { 90 }

sub make_reference_arrow {
	my( $pdf, $start, $angle, $length ) = @_;

	my $arrow_end = $start->clone;
	$arrow_end->add_x( $length * sin( $angle * 2 * 3.14 / 360 ) );
	$arrow_end->add_y( $length * cos( $angle * 2 * 3.14 / 360 ) );

	# the line needs to end before the pointy tip of the arrow,
	# so back off a little
	my $line_end = $arrow_end->clone;
	$line_end->add_x( -2 * sin( $angle * 2 * 3.14 / 360 ) );
	$line_end->add_y( -2 * cos( $angle * 2 * 3.14 / 360 ) );

	my $L = 8;
	my $l = 8;

	my $beta = 10;

	my $arrow_retro_tip_high = $arrow_end->clone;
	my $arrow_retro_tip_low  = $arrow_end->clone;

	$arrow_retro_tip_high->add_x( - $L*sin( $angle * 2 * 3.14 / 360 ) - $l * cos( $angle * 2 * 3.14 / 360 ) / 2 );
	$arrow_retro_tip_high->add_y( - $L*cos( $angle * 2 * 3.14 / 360 ) + $l * sin( $angle * 2 * 3.14 / 360 ) / 2 );

	$arrow_retro_tip_low->add_x( - $L*sin( $angle * 2 * 3.14 / 360 ) + $l * cos( $angle * 2 * 3.14 / 360 ) / 2 );
	$arrow_retro_tip_low->add_y( - $L*cos( $angle * 2 * 3.14 / 360 ) - $l * sin( $angle * 2 * 3.14 / 360 ) / 2 );

	$pdf->lines_xy( $start, $line_end );

=pod

	$pdf->lines( $end_x, $end_y, $arrow_tip1_x, $arrow_tip1_y );
	$pdf->lines( $end_x, $end_y, $arrow_tip2_x, $arrow_tip2_y );

	$pdf->lines( $arrow_tip1_x + $pdf->stroke_width, $arrow_tip1_y, $arrow_tip2_x + $pdf->stroke_width, $arrow_tip2_y );

=cut

 	$pdf->filledPolygon(
 		$arrow_end->xy,
 		$arrow_retro_tip_high->xy,
 		$arrow_retro_tip_low->xy,
 		);

  	return $arrow_end;
	}

sub lines_xy {
	my( $pdf, $start, $end ) = @_;

	$pdf->SUPER::lines(
		$start->xy,
		$end->xy,
		);
	}

sub make_reference_icon {
	my( $pdf, $center ) = @_;

	$pdf->make_magic_circle(
		$center,
		$pdf->box_height / 6,
		);

	$center;
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

sub make_scalar {
	my( $pdf, $name, $value, $bottom_left_x, $bottom_left_y ) = @_;

	my $length = max( map { length $_ } $name, $$value );

	my $scalar_width  = $pdf->font_width * $length;
	my $scalar_height = 10;

	$pdf->make_pointy_box(
		$bottom_left_x,
		$bottom_left_y,
		$scalar_width + 2 * $pdf->x_padding,
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

sub make_array {
	my( $pdf, $name, $array, $bottom_left_x, $bottom_left_y ) = @_;

	my $length = max( map { length $_ } $name, grep { ! ref $_ } @$array );

	my $scalar_width  = $pdf->font_width * $length;

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

	$pdf->make_list(
		$array,
		$bottom_left_x,
		$bottom_left_y - $pdf->connector_height - $pdf->black_bar_height,
		$scalar_width + 2 * $pdf->x_padding
		);

	}

sub make_list {
	my( $pdf, $array, $bottom_left_x, $bottom_left_y, $width ) = @_;

	my $scalar_width = $width || $pdf->get_list_width( $array );

	$pdf->make_collection_bar(
		$bottom_left_x,
		$bottom_left_y,
		$scalar_width + $pdf->pointy_width + $pdf->x_padding,
		);

	my $count = 0;
	foreach my $value ( @$array ) {
		$count++;

		my $box_value = ref $value ? '' : $value;
		$pdf->make_text_box(
			$bottom_left_x,
			$bottom_left_y - $count*($pdf->font_height + 2 * $pdf->y_padding),
			$scalar_width  + $pdf->x_padding,
			$pdf->box_height,
			\ $box_value
			);

		if( ref $value ) {
			my $center = XYPoint->new(
				$bottom_left_x + ( $scalar_width + $pdf->x_padding )/2 + $pdf->x_padding,
				$bottom_left_y + $pdf->box_height / 2 - $count*$pdf->box_height,
				);

			$pdf->make_reference_icon( $center );

			my $arrow_end = $pdf->make_reference_arrow(
				$center,
				$pdf->arrow_angle,
				$pdf->arrow_length( $scalar_width + $pdf->x_padding ),
				);

			my $ref_start = $arrow_end->clone;
			$ref_start->add_y( - $pdf->black_bar_height / 2 );

			if( ref $value eq ref [] ) {
				$pdf->make_list( $value, $ref_start->xy );
				}
			elsif( ref $value eq ref {} ) {
				$pdf->make_anonymous_hash( $value, $ref_start->xy );
				}
			}
		}

	}

sub get_list_height {
	my( $pdf, $array ) = @_;

	}

sub minimum_scalar_width { 3 * $_[0]->font_width }
sub get_list_width {
	my( $pdf, $array ) = @_;

	my $length = max( map { length $_ }  grep { ! ref $_ } @$array );

	my $scalar_width  = max( $pdf->minimum_scalar_width, $pdf->font_width * $length );
	}

sub make_hash {
	my( $pdf, $name, $hash, $bottom_left_x, $bottom_left_y ) = @_;

	my( $key_length, $value_length ) = $pdf->get_hash_lengths( $hash );

	my $scalar_width  = $pdf->font_width * ( $key_length + $value_length ) + 4 * $pdf->x_padding + $pdf->pointy_width;

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

	$pdf->make_anonymous_hash(
		$hash,
		$bottom_left_x,
		$bottom_left_y - $pdf->connector_height - $pdf->black_bar_height,
		);

	}

sub get_hash_lengths {
	my( $pdf, $hash ) = @_;

	my $key_length   = max( map { length $_ } keys %$hash );
	my $value_length = max( map { length $_ } grep { ! ref $_ } values %$hash );

	( $key_length, $value_length );
	}

sub make_anonymous_hash {
	my( $pdf, $hash, $bottom_left_x, $bottom_left_y ) = @_;

	my( $key_length, $value_length ) = $pdf->get_hash_lengths( $hash );

	my $scalar_width  =
		$pdf->font_width * ( $key_length + $value_length ) +
		4 * $pdf->x_padding                                +
		$pdf->pointy_width;

	$pdf->make_collection_bar(
		$bottom_left_x,
		$bottom_left_y,
		$scalar_width + $pdf->pointy_width,
		);

	my $count = 0;
	foreach my $key ( keys %$hash ) {
		$count++;

		my $key_box_width =
			$pdf->font_width * $key_length + 1 * $pdf->x_padding + $pdf->pointy_width / 2;

			; # share name box extra

		$pdf->make_pointy_box(
			$bottom_left_x,
			$bottom_left_y - $count*($pdf->font_height + 2 * $pdf->y_padding),
			$key_box_width,
			$pdf->box_height,
			$key
			);

		$pdf->make_text_box(
			$bottom_left_x + $key_box_width + $pdf->pointy_width + 2 * $pdf->stroke_width,
			$bottom_left_y - $count*($pdf->font_height + 2 * $pdf->y_padding),
			$pdf->font_width * $value_length + $pdf->x_padding - 2.125*$pdf->stroke_width,
			$pdf->box_height,
			\ $hash->{$key}
			);
		}

	}


sub make_collection_bar {
	my( $pdf, $bottom_left_x, $bottom_left_y, $width ) = @_;

	my $height = $pdf->black_bar_height;

	$pdf->filledRectangle(
		$bottom_left_x - $pdf->stroke_width,
		$bottom_left_y,
		$width + 2 * $pdf->stroke_width,
		$height,
		);

	$pdf->strokePath;
	}

sub make_text_box {
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

sub make_pointy_box {
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

=back

=head1 TO DO


=head1 SEE ALSO


=head1 SOURCE AVAILABILITY

This source is in Github:

	http://github.com/briandfoy/pegs-pdf/

=head1 AUTHOR

brian d foy, C<< <bdfoy@cpan.org> >>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2009-2014, brian d foy, All Rights Reserved.

You may redistribute this under the same terms as Perl itself.

=cut


BEGIN {
	package XYPoint;

	sub new { bless [ @_[1,2] ], $_[0] }
	sub x { $_[0][0] }
	sub y { $_[0][1] }

	sub add_x { $_[0][0] += $_[1] }
	sub add_y { $_[0][1] += $_[1] }

	sub xy { ( $_[0]->x, $_[0]->y ) }

	sub clone { (ref $_[0])->new( $_[0]->xy ) }

	sub as_string { sprintf "(%d, %d)", $_[0]->x, $_[0]->y }
	}

1;
