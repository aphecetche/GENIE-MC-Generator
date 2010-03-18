#!/usr/bin/perl

#------------------------------------------------------------------------------------------
# Submit jobs for calculating GENIE cross section splines for all nuclear targets 
# and at the energy range required for generating the GENIE release validation samples.
#
# For use at the RAL/PPD Tier2 PBS batch farm.
#
# Syntax:
#   shell% perl submit-xsec_vldsamples.pl <options>
#
# Options:
#    --version       : GENIE version number
#   [--arch]         : <SL4_32bit, SL5_64bit>, default: SL5_64bit
#   [--production]   : default: <version>
#   [--cycle]        : default: 01
#   [--use-valgrind] : default: off
#   [--batch-system] : <PBS, >, default: PBS
#   [--queue]        : default: prod
#   [--softw-topdir] : default: /opt/ppd/t2k/GENIE
#
# Notes:
#   * Use GENIE gspladd utility to merge the job outputs
#
# Tested at the RAL/PPD Tier2 PBS batch farm.
#
# Costas Andreopoulos <costas.andreopoulos \at stfc.ac.uk>
# STFC, Rutherford Appleton Lab
#------------------------------------------------------------------------------------------

use File::Path;

# inputs
#  
$iarg=0;
foreach (@ARGV) {
  if($_ eq '--version')       { $genie_version = $ARGV[$iarg+1]; }
  if($_ eq '--arch')          { $arch          = $ARGV[$iarg+1]; }
  if($_ eq '--production')    { $production    = $ARGV[$iarg+1]; }
  if($_ eq '--cycle')         { $cycle         = $ARGV[$iarg+1]; }
  if($_ eq '--use-valgrind')  { $use_valgrind  = $ARGV[$iarg+1]; }
  if($_ eq '--batch-system')  { $batch_system  = $ARGV[$iarg+1]; }
  if($_ eq '--queue')         { $queue         = $ARGV[$iarg+1]; }
  if($_ eq '--softw-topdir')  { $softw_topdir  = $ARGV[$iarg+1]; }
  $iarg++;
}
die("** Aborting [Undefined GENIE version. Use the --version option]")
unless defined $genie_version;

$use_valgrind   = 0                         unless defined $use_valgrind;
$arch           = "SL5_64bit"               unless defined $arch;
$production     = "$genie_version"          unless defined $production;
$cycle          = "01"                      unless defined $cycle;
$batch_system   = "PBS"                     unless defined $batch_system;
$queue          = "prod"                    unless defined $queue;
$softw_topdir   = "/opt/ppd/t2k/GENIE"      unless defined $softw_topdir;
$genie_setup    = "$softw_topdir/builds/$arch/$genie_version-setup";
$jobs_dir       = "$softw_topdir/scratch/xsec\_vldsamples-$production\_$cycle/";
$freenucsplines = "$softw_topdir/data/job_inputs/xspl/gxspl-freenuc-$genie_version.xml";

$nkots     = 1000;
$emax      =  150;
$neutrinos = "12,-12,14,-14";
%targets = (
	'C12'   =>  '1000060120',
	'O16'   =>  '1000080160', 
        'Ne20'  =>  '1000100200',
        'Al27'  =>  '1000130270',
        'Si30'  =>  '1000140300',
	'Ar38'  =>  '1000180380',
	'Fe56'  =>  '1000260560' 
           );

# make the jobs directory
#
mkpath ($jobs_dir, {verbose => 1, mode=>0777});

#
# loop over nuclear targets & submit jobs
#
while( my ($tgt_name, $tgt_code) = each %targets ) {

    $job_file_base = "$jobs_dir/job_$tgt_name";
    $cmd = "gmkspl -p $neutrinos -t $tgt_code -n $nkots -e $emax -o gxspl_$tgt_name.xml &> $job_file_base.mkspl.log";
    print "@@ exec: $cmd \n";

    #
    # submit
    #
  
    # PBS case
    if($batch_system eq 'PBS') {
	$batch_script = "$job_file_base.pbs";
	open(PBS, ">$batch_script") or die("Can not create the PBS batch script");
	print PBS "#!/bin/bash \n";
        print PBS "#PBS -N $tgt_name \n";
        print PBS "#PBS -o $job_file_base.pbsout.log \n";
        print PBS "#PBS -e $job_file_base.pbserr.log \n";
	print PBS "source $genie_setup \n";
	print PBS "cd $jobs_dir \n";
	print PBS "export GSPLOAD=$freenucsplines\n";
	print PBS "$cmd \n";
        close(PBS);
	`qsub -q $queue $BATCH_SCRIPT`;
    } #PBS

}
