#!/usr/bin/perl

# this is hackish.. didn't know how to do it with normal C Unix calls :(

$numArgs = $#ARGV + 1;
if ($numArgs == 1)
{
	$ipod = $ARGV[0];

	$mounts = `/sbin/mount`;
	if ($mounts =~ /\/dev\/disk(\d)s\d on ${ipod}/gsi)
	{
		print $1;
	}
}