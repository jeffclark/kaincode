#!/usr/bin/perl

$sysInfo = "";
while ($line = <STDIN>)
{
	$sysInfo .= $line;
}

if ($sysInfo =~ /boardHwSwInterfaceRev: 0x000(\d)/gs)
{
	$gen = $1;
	print $gen;
}
else
{
	print "-1";
}