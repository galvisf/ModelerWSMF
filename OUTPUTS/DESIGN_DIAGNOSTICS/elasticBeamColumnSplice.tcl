########################################################################################################
# elasticBeamColumnSplice.tcl                                                                         
#
# SubRoutine to construct an elastic beam or column element with a spring splice in a given location
#                                                      
########################################################################################################
#
# Input Arguments:
#------------------
# eleTag 				Element ID
# node_i 				Initial node
# node_j 				End node
# eleDir				'Horizontal'
#						'Vertical'
# transfTag 			1 -> Linear 
#						2 -> PDelta
#						3 -> Corotational
# Es					Elastic modulus [ksi]
# rigMatTag				tag of a pre-created elastic material with large E
# A						Cross-sectional area of the element [in^2]
# Ieff					Second moment of area of the section [in^4]
# spliceLoc				Splice location measured from node_i [in]
# 
# Written by: Francisco Galvis, Stanford University
#
proc elasticBeamColumnSplice { eleTag node_i node_j eleDir transfTag Es rigMatTag A Ieff spliceLoc} {

	## Create intermediate nodes for splices ##
	set nodeSpl1 [expr $node_i+30]
	set nodeSpl2 [expr $node_i+40]
	
	set n1Coord [nodeCoord $node_i]
	set x1 [lindex $n1Coord 0]
	set y1 [lindex $n1Coord 1]
	set n2Coord [nodeCoord $node_j]
	set x2 [lindex $n2Coord 0]
	set y2 [lindex $n2Coord 1]
	
	if {$eleDir == "Horizontal"} {
		set x3 [expr $x1 + $spliceLoc]
		set y3 $y1;
		node $nodeSpl1 [expr $x3 - 0] $y3	
		node $nodeSpl2 [expr $x3 + 0] $y3
	} else {
		set x3 $x1
		set y3 [expr $y1 + $spliceLoc]
		node $nodeSpl1 $x3 [expr $y3 - 0]
		node $nodeSpl2 $x3 [expr $y3 + 0]
	}	
	
	## Get element length ##	
	if {$eleDir == "Horizontal"} {
		set eleLength [expr $x2 - $x1]
	} elseif {$eleDir == "Vertical"} {
		set eleLength [expr $y2 - $y1]
	} else {
		puts "ERROR: specify Horizontal or Vertical element direction"
	}
	
	## Read inputs for splice element ##
	## Define stiffness constants
	set EIeff [expr $Es*$Ieff]
	set EA [expr $Es*$A]		
	
	## Create splice section ##
	set rigSecTag [expr $eleTag + 30]
	uniaxialMaterial Elastic $rigSecTag 1e9;

	## Create elements ##
	set eleTag2 [expr $eleTag+2];
	set spliceEleTag [expr $eleTag+5];

	# Elastic elements between end springs
	element elasticBeamColumn   $eleTag $node_i $nodeSpl1 $A $Es $Ieff $transfTag;
	element elasticBeamColumn   $eleTag2 $nodeSpl2 $node_j $A $Es $Ieff $transfTag;

	# Splice element
	equalDOF $nodeSpl1 $nodeSpl2 1 2
	element zeroLength $spliceEleTag $nodeSpl1 $nodeSpl2 -mat $rigSecTag -dir 6
	
}

########################################################################################################
# elasticBeamColumnSpliceFiber.tcl                                                                         
#
# SubRoutine to construct an elastic beam or column element with a fiber section splice in a given location
#                                                      
########################################################################################################
#
# Input Arguments:
#------------------
# eleTag 				Element ID
# node_i 				Initial node
# node_j 				End node
# eleDir				'Horizontal'
#						'Vertical'
# transfTag 			1 -> Linear 
#						2 -> PDelta
#						3 -> Corotational
# Es					Elastic modulus [ksi]
# rigMatTag				tag of a pre-created elastic material with large E
# A						Cross-sectional area of the element [in^2]
# Ieff					Second moment of area of the section [in^4]
# spliceLoc				Splice location measured from node_i [in]
# spliceSecGeometry		list with the dimensions of the splice section
#						{d, bf, tf, tw}
# ttab 					thickness of the shear tab [in]
# dtab					depth of the web welded to the column (assumed centered in the beam depth) [in]
# 
# Written by: Francisco Galvis, Stanford University
#

proc elasticBeamColumnSpliceFiber { eleTag node_i node_j eleDir transfTag Es rigMatTag A Ieff spliceLoc  spliceSecGeometry ttab dtab} {

	## Create intermediate nodes for splices ##
	set nodeSpl1 [expr $node_i+30]
	set nodeSpl2 [expr $node_i+40]
	
	set n1Coord [nodeCoord $node_i]
	set x1 [lindex $n1Coord 0]
	set y1 [lindex $n1Coord 1]
	set n2Coord [nodeCoord $node_j]
	set x2 [lindex $n2Coord 0]
	set y2 [lindex $n2Coord 1]
	
	if {$eleDir == "Horizontal"} {
		set x3 [expr $x1 + $spliceLoc]
		set y3 $y1;
		node $nodeSpl1 [expr $x3 - 0] $y3	
		node $nodeSpl2 [expr $x3 + 0] $y3
	} else {
		set x3 $x1
		set y3 [expr $y1 + $spliceLoc]
		node $nodeSpl1 $x3 [expr $y3 - 0]
		node $nodeSpl2 $x3 [expr $y3 + 0]
	}	
	
	## Get element length ##	
	if {$eleDir == "Horizontal"} {
		set eleLength [expr $x2 - $x1]
	} elseif {$eleDir == "Vertical"} {
		set eleLength [expr $y2 - $y1]
	} else {
		puts "ERROR: specify Horizontal or Vertical element direction"
	}
	
	## Read inputs for splice element ##
	# Beam profile and tab geometry
	set d [lindex $spliceSecGeometry 0]
	set bf [lindex $spliceSecGeometry 1]
	set tf [lindex $spliceSecGeometry 2]
	set tw [lindex $spliceSecGeometry 3]
	
	## Define stiffness constants
	set EIeff [expr $Es*$Ieff]
	set EA [expr $Es*$A]		
	
	## Create splice section ##
	set spliceSecTag [expr $eleTag + 10]
	set webMatTag [expr $eleTag+10]
	set FySplice 1000; # to ensure elastic response
	fracSectionSplice $spliceSecTag $eleDir [expr $eleTag+1] $FySplice $webMatTag $d $bf $tf $ttab $dtab $FySplice $Es

	set rigSecTag [expr $eleTag + 30]
	set spliceSecTag2 [expr $eleTag + 20]
	uniaxialMaterial Elastic $rigSecTag 1e9;
	section Aggregator $spliceSecTag2 $rigSecTag Vy -section $spliceSecTag	
	
	## Create elements ##
	set eleTag2 [expr $eleTag+2];
	set spliceEleTag [expr $eleTag+5];

	# Elastic elements between end springs
	element elasticBeamColumn   $eleTag $node_i $nodeSpl1 $A $Es $Ieff $transfTag;
	element elasticBeamColumn   $eleTag2 $nodeSpl2 $node_j $A $Es $Ieff $transfTag;

	# Splice element
	element zeroLengthSection $spliceEleTag $nodeSpl1 $nodeSpl2 $spliceSecTag2
	
}