proc Wsection { secID matID d bf tf tw nfdw nftw nfbf nftf} {
	# ###################################################################
	# Wsection  $secID $matID $d $bf $tf $tw $nfdw $nftw $nfbf $nftf
	# ###################################################################
	# create a standard W section given the nominal section properties
	# written: Remo M. de Souza
	# date: 06/99
	# modified: 08/99  (according to the new general modelbuilder)
	# input parameters
	# secID - section ID number
	# matID - material ID number 
	# d  = nominal depth
	# tw = web thickness
	# bf = flange width
	# tf = flange thickness
	# nfdw = number of fibers along web depth 
	# nftw = number of fibers along web thickness
	# nfbf = number of fibers along flange width
	# nftf = number of fibers along flange thickness
  	
	set dw [expr $d - 2 * $tf]
	set y1 [expr -$d/2]
	set y2 [expr -$dw/2]
	set y3 [expr  $dw/2]
	set y4 [expr  $d/2]
  
	set z1 [expr -$bf/2]
	set z2 [expr -$tw/2]
	set z3 [expr  $tw/2]
	set z4 [expr  $bf/2]
  
	section fiberSec  $secID  {
   		#                     nfIJ  nfJK    yI  zI    yJ  zJ    yK  zK    yL  zL
   		patch quadr  $matID  $nfbf $nftf   $y1 $z4   $y1 $z1   $y2 $z1   $y2 $z4
   		patch quadr  $matID  $nftw $nfdw   $y2 $z3   $y2 $z2   $y3 $z2   $y3 $z3
   		patch quadr  $matID  $nfbf $nftf   $y3 $z4   $y3 $z1   $y4 $z1   $y4 $z4
	}
}

proc WsectionSlab { secID matID d bf tf tw nfdw nftw nfbf nftf trib tslab bslab} {
	# ###################################################################
	# Wsection  $secID $matID $d $bf $tf $tw $nfdw $nftw $nfbf $nftf
	# ###################################################################
	# create a standard W section given the nominal section properties
	# written: Remo M. de Souza
	# date: 06/99
	# modified: 08/99  (according to the new general modelbuilder)
	# input parameters
	# secID - section ID number
	# matID - material ID number 
	# d  = nominal depth
	# tw = web thickness
	# bf = flange width
	# tf = flange thickness
	# nfdw = number of fibers along web depth 
	# nftw = number of fibers along web thickness
	# nfbf = number of fibers along flange width
	# nftf = number of fibers along flange thickness
  	
	set dw [expr $d - 2 * $tf]
	set y1 [expr -$d/2]
	set y2 [expr -$dw/2]
	set y3 [expr  $dw/2]
	set y4 [expr  $d/2]
  
	set z1 [expr -$bf/2]
	set z2 [expr -$tw/2]
	set z3 [expr  $tw/2]
	set z4 [expr  $bf/2]
  
	# fiber area and location (slab)
	set ytop [expr ($d-$tf)/2];
	set yslab [expr $ytop + $trib + $tslab/2]
	set Aslab [expr ($tslab + $trib/2) * $bslab /10 * 0.35]; # equivalent top steel to replace slab (assume 35% composite action and Es/Ec = 10)
  
	section fiberSec  $secID  {
   		#                     nfIJ  nfJK    yI  zI    yJ  zJ    yK  zK    yL  zL
   		patch quadr  $matID  $nfbf $nftf   $y1 $z4   $y1 $z1   $y2 $z1   $y2 $z4
   		patch quadr  $matID  $nftw $nfdw   $y2 $z3   $y2 $z2   $y3 $z2   $y3 $z3
   		patch quadr  $matID  $nfbf $nftf   $y3 $z4   $y3 $z1   $y4 $z1   $y4 $z4
		
		# Slab
		fiber $yslab 0.0 $Aslab $matID;
	}
}

proc WsectionSplice { secID matIDf matIDw d bf tf tw nfdw nftw nfbf nftf} {
	# ###################################################################
	# Wsection  $secID $matID $d $bf $tf $tw $nfdw $nftw $nfbf $nftf
	# ###################################################################
	# create a standard W section given the nominal section properties
	# written: Remo M. de Souza
	# date: 06/99
	# modified: 08/99  (according to the new general modelbuilder)
	# input parameters
	# secID - section ID number
	# matID - material ID number for flanges
	# matID - material ID number for web
	# d  = nominal depth
	# tw = web thickness
	# bf = flange width
	# tf = flange thickness
	# nfdw = number of fibers along web depth 
	# nftw = number of fibers along web thickness
	# nfbf = number of fibers along flange width
	# nftf = number of fibers along flange thickness
  	
	set dw [expr $d - 2 * $tf]
	set y1 [expr -$d/2]
	set y2 [expr -$dw/2]
	set y3 [expr  $dw/2]
	set y4 [expr  $d/2]
  
	set z1 [expr -$bf/2]
	set z2 [expr -$tw/2]
	set z3 [expr  $tw/2]
	set z4 [expr  $bf/2]
  
	section fiberSec  $secID  {
   		#                     nfIJ  nfJK    yI  zI    yJ  zJ    yK  zK    yL  zL
   		patch quadr  $matIDf  $nfbf $nftf   $y1 $z4   $y1 $z1   $y2 $z1   $y2 $z4
   		patch quadr  $matIDw  $nftw $nfdw   $y2 $z3   $y2 $z2   $y3 $z2   $y3 $z3
   		patch quadr  $matIDf  $nfbf $nftf   $y3 $z4   $y3 $z1   $y4 $z1   $y4 $z4
	}
}
