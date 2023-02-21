<p align="center"> Modeler WSMF

## What is it?
`ModelerWSMF` is an open-source Matlab-based package that facilitates the automatic generation of 2D OpenSees (.tcl) models of moment resisiting frames with special emphasis on welded steel moment frames (WSMF).
The package is capable of generating state-of-the-art non-linear models that consider high-fidelity simulations of panel zones, welded beam-to-column connections, and columns splices as depicted in Figure 1.

<p align="center"> <img src="https://user-images.githubusercontent.com/35354704/202242564-2c0335b3-5606-4451-9961-990533ad0e56.png" align="middle" height=400 /></p>
<p align="center"> Figure 1. OpenSees 2D frame modeling details. 

This code extends already available open-source packages (notably https://github.com/amaelkady/FM-2D) by including the capabilities to model irregular buildings that might have setbacks, atypical story heights, MEP floors, interrupted column lines, atriums, and podiums. These capabililities are envision to be included in FM-2D in the future.

`ModelerWSMF` was the primary engine to generate the models that support the following publications:  
  
- *Galvis, F. A. (2022). “Seismic Risk and Post-Earthquake Recovery of Older Tall Buidings with Welded Steel Moment Frames.”Ph.D. thesis. John A. Blume Earthquake Engineering Center, Stanford University.*
  
- *Galvis, F. A., Deierlein, G. G., Yen, W., and Molina Hutt, C., Correal J. F., (2022). Detailed Database of Tall Pre-Northridge Steel Moment Frames for Earthquake Performance Evaluations. (In review).*
  
- *Galvis, F. A., Deierlein, G. G., Zsarnoczay3, A., and Molina Hutt, C., (2022). Seismic screening method for tall pre-Northridge welded steel moment frames based on the collapse risk of a realistic portfolio. (In preparation).*
  
## How can I use it?
The first step of the modeling process is creating the frame input file in excel format and store it in the ***INPUTS*** folder. This file includes all the details of the frame to model (see examples in the **INPUTs** folder for details).  
The repository has three main scripts that use the supporting functions and databases stores in the ***SRC*** folder and the input excel file per frame to generate OpenSees models and run some analysis that help you check the model.
  
- *main_ModelGenerator.m: Takes the input file for the frame and produces an OpenSees model that is stored in the ***OUTPUTS*** folder.
  
- *main_DesignDiagnostics.m: Takes the input file for the frame, calculates typical design checks that serve to diagnose the frame seismic performance. Examples of these diagnistics are: Strong-Column-to-Weak-Beam ratio per floor, axial load ratios per column, panel zone strenght ratios, period and mode shapes, and wind and seismic drift profiles. To estimat the modal parameters and the drift profiles, the script generates linear OpenSees models of the frame and applies the equivalent lateral force corresponding to the applicable UBC associated to the year of construction of the frame. The script summarizes all these information in a single dashboard (See example in Figure 2). All the supporting files and final summary figure are stores in the ***OUTPUTS*** folder.

- *main_Pushover.m: Takes the input file for the frame, produces a nonlinear OpenSees model, and runs a pushover analysis using a lateral force pattern equal to the first mode shape. The pushover results and the model are stored in the ***OUTPUTS*** folder.
  
<p align="center"> <img src="https://user-images.githubusercontent.com/35354704/202243408-361accfd-56d0-4e37-ace5-61936db8a28b.png" align="middle" height=400 /></p>
<p align="center"> Figure 2. Example of the design diagnostics dashboard. 

Current code has been checked with Matlab 2020 and newer.
  
## Post-processing options
OpenSees produces output in a series of text files that need post-processing for effective interrogation. To this end, the folder **POSTPROCESSING** includes two sample Jupyter notebooks that facilitate this postprocessing by collecting the output data and ploting it in convenient ways. These notebooks harness the open-access module **galvisf/frame_postprocess**.

## Main structural modeling features

**(1)** This package supports linear and non-linear model generation using concentrated plasticity models using the backbones per any of the following documents (more details in **SRC/steelBeamHinge.m** and **SRC/steelColumnHinge.m**):
  
  - *NIST (2017). “Guidelines for Nonlinear Structural Analysis for Design of Buildings Part IIb – Concrete Moment Frames”* (first-cycle envelope or monotonic envelope+cyclic degradation using IMK hinges)
  
  - *ASCE/SEI 41 (2017). “Seismic Evaluation and Retrofit of Existing Buildings ”*
  
  - *AISC 342 - draft (2023). “Seismic Provisions for Evaluation and Retrofit of Existing Structural Steel Buildings ”* (Only for box columns)
  
**(2)** Beams could be built-upwide-flange section and standard sections included in the extended database provided in **0_Databases**. Columns could be built-up wide-flange sections, standard wide-flange sections, or box columns. The format for the input file to specify the different type of sections is the following (more details in **SRC/getSteelSectionProps.m**):
  
  - String with name of the section as is in **0_Databases/AISC_v14p1.mat**
  
  - Built-up wide flange sections (BUILT db-bf-tw-tf'): 'BUILT ##.##-##.##-#.###-#.###'
  
  - Box sections ('BOX db-bf-tw-tf'): 'BOX ##.##-##.##-#.###-#.###'
  
**(3)** Panel zone behavior could be included using any of the following assumptions (mode details in **SRC/PanelZoneSpring.tcl**):
  
  - None (rigid connection)
  - Elastic spring assuming only column web stiffness
  - Nonlinear backbone per *Gupta and Krawinkler (1999)*
  - Nonlinear backbone per *NIST (2017)*
  - Nonlinear backbone per *Kim et al. (2015)*
  - Nonlinear backbone per *Skiadopoulos et al. (2021)*
  
**(4)** Beams can me simulated with and without composite action. Composite action increases elastic stiffness as well as modify the backbone per NIST (2017) modeling guidelines (variable "composite").

**(5)** The model can include or ignore the stiffness and strength contribution of the gravity system (variable "addEGF").

**(6)** Beam-to-column connections can be simulated with typical backbone curves or using a fiber-section with the novel material **SteelFractureDI** for simulating welded-flange fracture.
  
## How can I get started?

The ***INPUTS*** folder includes some ready to use examples to facilitate testing of the package. The file "inputs_TestBldg.xlsx" correspond to an unrealistically irregular building that showcase the capabilities of the package to simulate structurally irregular frames. Use this example with the "main_DesignDiagnostics.m" module for more details. Note that the "inputs_TestBldg.xlsx" frame is not suitable for nonlinear analyses (i.e., pushover or NLRHA) because of the unbalance nature of the structural system. The remaining examples are suitable for testing all modules.

## License

`ModelerWSMF` is distributed under the MIT license, see [LICENSE](https://opensource.org/licenses/MIT).

## Contact

Francisco Galvis, galvisf@alumni.stanford.edu 
  
