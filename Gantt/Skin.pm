##########################################################################
#
#	File:	Project/Gantt/Skin.pm
#
#	Author:	Alexander Westholm
#
#	Purpose: This object contains visualization preferences that can
#		alter the look and feel of a chart. The default values
#		create a fairly conservative blue/grey scheme.
#
#	Client:	CPAN
#
#	CVS: $Id: Skin.pm,v 1.4 2004/08/02 06:14:41 awestholm Exp $
#
##########################################################################
package Project::Gantt::Skin;
use strict;
use warnings;
use vars qw[$AUTOLOAD];

##########################################################################
#
#	Method:	new(%opts)
#
#	Purpose: Constructor. See code for parameters. Note that all
#		parameters have default values. As mentioned above, the
#		defaults create a fairly conservative blue/grey scheme
#
##########################################################################
sub new {
	my $cls	= shift;
	my %ops	= @_;
	my %members	= (
		primaryText	=>	$ops{primaryText}	|| 'black',
		secondaryText	=>	$ops{secondaryText}	|| '#969696',
		primaryFill	=>	$ops{primaryFill}	|| '#c4dbed',
		secondaryFill	=>	$ops{secondaryFill}	|| '#e5e5e5',
		infoStroke	=>	$ops{infoStroke}	|| 'black',
		doTitle		=>	(defined($ops{doTitle})?$ops{doTitle}:1),
		containerStroke	=>	$ops{containerStroke}	|| 'black',
		containerFill	=>	$ops{containerFill}	|| 'grey',
		itemFill	=>	$ops{itemFill}		|| 'blue',
		background	=>	$ops{background}	|| 'white',
		font		=>	$ops{font}		|| '@font.ttf',
		doSwimLanes	=>	(defined($ops{doSwimLanes})?$ops{doSwimLanes}:1),
	);
	return bless \%members, $cls;
}

##########################################################################
#
#	Method:	AUTOLOAD
#
#	Purpose: An AUTOLOAD handler is installed because this class
#		contains nothing but data. Therefor, the only methods
#		necesarry are accessors, provided by this catch all
#
##########################################################################
sub AUTOLOAD {
	my $me	= shift;
	my $var	= $AUTOLOAD;
	$var	=~ s/.*:://;
	return $me->{$var};
}

1;
