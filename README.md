<p align="center"> Modeler WSMF

## What is it?
ModelerWSMF is an open-source Matlab-based package that facilitates the automatic generation of 2D OpenSees (.tcl) models of moment resisiting frames with special emphasis on welded steel moment frames (WSMF).
The package is capable of generating state-of-the-art non-linear models that consider high-fidelity simulations of panel zones, welded beam-to-column connections, and columns splices as depicted in Figure 1.
  

<p align="center"> Figure 1. OpenSees 2D frame modeling details. 

This code extends already available open-source packages (notably https://github.com/amaelkady/FM-2D) by including the capabilities to model irregular buildings that might have setbacks, atypical story heights, MEP floors, interrupted column lines, atriums, and podiums. These capabililities are envision to be included in FM-2D in the near future.

ModelerWSMF was the primary engine to generate the models that support the following publications:  
  
- *Galvis, F. A. (2022). “Seismic Risk and Post-Earthquake Recovery of Older Tall Buidings with Welded Steel Moment Frames.”Ph.D. thesis. John A. Blume Earthquake Engineering Center, Stanford University.*
  
- *Galvis, F. A., Deierlein, G. G., Yen, W., and Molina Hutt, C., Correal J. F., (2022). Detailed Database of Tall Pre-Northridge Steel Moment Frames for Earthquake Performance Evaluations. (In review).*
  
- *Galvis, F. A., Deierlein, G. G., Zsarnoczay3, A., and Molina Hutt, C., (2022). Seismic screening method for tall pre-Northridge welded steel moment frames based on the collapse risk of a realistic portfolio. (In preparation).*
  
## How can I use it?
The first step of the modeling process is creating the frame input file in excel format and store it in the ***INPUTS*** folder. This file includes all the details of the frame to model (see example of irregular building for details).  
The repository has three main scripts that use the supporting functions and databases stores in the ***SRC*** folder and the input excel file per frame to generate OpenSees models and run some analysis that help you check the model.
  
- *main_ModelGenerator.m: Takes the input file for the frame and produces an OpenSees model that is stored in the ***OUTPUTS*** folder.
  
- *main_DesignDiagnostics.m: Takes the input file for the frame, calculates typical design checks that serve to diagnose the frame seismic performance. Examples of these diagnistics are: Strong-Column-to-Weak-Beam ratio per floor, axial load ratios per column, panel zone strenght ratios, period and mode shapes, and wind and seismic drift profiles. To estimat the modal parameters and the drift profiles, the script generates linear OpenSees models of the frame and applies the equivalent lateral force corresponding to the applicable UBC associated to the year of construction of the frame. The script summarizes all these information in a single figure. All the supporting files and final summary figure are stores in the ***OUTPUTS*** folder.

- *main_Pushover.m: Takes the input file for the frame, produces a nonlinear OpenSees model, and runs a pushover analysis using a lateral force pattern equal to the first mode shape. The pushover results and the model are stored in the ***OUTPUTS*** folder.
  

## License

ModelerWSMF is distributed under the MIT license, see [LICENSE](https://opensource.org/licenses/MIT).

## Contact

Francisco Galvis, galvisf@alumni.stanford.edu 
  
