##########################################################################
#
#	File:	Project/Gantt/ImageWriter.pm
#
#	Author:	Alexander Westholm
#
#	Purpose: The ImageWriter object coordinates the visualization
#		of scheduling data. It creates the canvas, and all
#		supporting objects that write different aspects of the
#		chart to the screen.
#
#	Client:	CPAN
#
#	CVS: $Id: ImageWriter.pm,v 1.14 2004/08/03 17:56:52 awestholm Exp $
#
##########################################################################
package Project::Gantt::ImageWriter;
use strict;
use warnings;
use Image::Magick;
use Project::Gantt::DateUtils qw[:round :lookup];
use Project::Gantt::Globals;
use Project::Gantt::GanttHeader;
use Project::Gantt::TimeSpan;
use Project::Gantt::SpanInfo;

##########################################################################
#
#	Method:	new(%opts)
#
#	Purpose: Constructor. Takes as parameters the mode of drawing
#		(hours, days, or months), the root Project::Gantt object,
#		and the skin in use.
#
##########################################################################
sub new {
	my $cls	= shift;
	my %opts= @_;
	if(not $opts{root}){
		die "Must supply root node to ImageWriter!";
	}
	$opts{mode} = 'days' if not $opts{mode};
	my $me 	= bless \%opts, $cls;
	$me->_getCanvas();
	return $me;
}

##########################################################################
#
#	Method:	_getCanvas()
#
#	Purpose: This method examines the root node, and sets the width
#		of the canvas based on the timespan covered by the chart,
#		and sets the height based on how many schedule items
#		constitute the chart.
#
##########################################################################
sub _getCanvas {
	my $me	= shift;
	my ($height, $width) = (0,0);
	$height = 40;
	# add height for each row
	$height += 20 for (1..$me->{root}->getNodeCount());
	$width	= 205;
	my $incr = $DAYSIZE;
	$incr = $MONTHSIZE if($me->{mode} eq 'months');
	# add width for each time unit
	$width += $incr for (1..$me->{root}->timeSpan());

	my $canvas = new Image::Magick(size=>"${width}x$height");
	$canvas->Read('xc:'.$me->{skin}->background());
	$me->{canvas} = $canvas;
}

##########################################################################
#
#	Method:	display(filename)
#
#	Purpose: Creates the Calendar header and draws it, then calls
#		writeBars to draw in all tasks/subprojects. Finally,
#		writes the image to a file.
#
##########################################################################
sub display {
	my $me	= shift;
	my $img	= shift;
	my $hdr	= new Project::Gantt::GanttHeader(
		canvas	=>	$me->{canvas},
		skin	=>	$me->{skin},
		root	=>	$me->{root});
	$hdr->display($me->{mode});
	$me->writeBars();
	$me->{canvas}->Write($img);
}

##########################################################################
#
#	Method:	writeBars()
#
#	Purpose: Iterates over all tasks/subprojects contained by the root
#		object, and creates SpanInfo and TimeSpan objects for each
#		item, then draws them.
#
##########################################################################
sub writeBars {
	my $me		= shift;
	my @tasks	= $me->{root}->getTasks();
	my @projs	= $me->{root}->getSubProjs();
	my $stDate	= $me->{root}->getStartDate();
	my $height	= 40;

	# write tasks before sub-projects.. adjust height as we go
	for my $tsk (@tasks,@projs){
		my $info= new Project::Gantt::SpanInfo(
			canvas	=>	$me->{canvas},
			skin	=>	$me->{skin},
			task	=>	$tsk);
		$info->display($height);
		my $bar	= new Project::Gantt::TimeSpan(
			canvas	=>	$me->{canvas},
			skin	=>	$me->{skin},
			task	=>	$tsk,
			rootStr	=>	$stDate);
		$bar->display($me->{mode},$height);
		$height	+= 20;
		if($tsk->isa("Project::Gantt")){
			for my $stsk ($tsk->getTasks()){
				my $ninfo= new Project::Gantt::SpanInfo(
					canvas	=>	$me->{canvas},
					skin	=>	$me->{skin},
					task	=>	$stsk);
				$ninfo->display($height);
				my $ibar	= new Project::Gantt::TimeSpan(
					canvas	=>	$me->{canvas},
					skin	=>	$me->{skin},
					task	=>	$stsk,
					rootStr	=>	$stDate);
				$ibar->display($me->{mode},$height);
				$height += 20;
			}
		}
	}
}

1;
