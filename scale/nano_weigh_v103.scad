/////////////////////////// - Info - //////////////////////////////
// All coordinates are starting as integrated circuit pins.
// From the top view :
//   CoordD           <---       CoordC
//                                 ^
//                                 ^
//                                 ^
//   CoordA           --->       CoordB
////////////////////////////////////////////////////////////////////

use <OpenSCAD_Libs/nano.scad>
use <OpenSCAD_Libs/hx711.scad>
use <Batteries_in_OpenSCAD/batteries.scad>
include <OpenSCAD_Libs/models/096OledDim.scad>; // OLED screen dimensions
use <OpenSCAD_Libs/models/096Oled.scad>; // OLED screen model
use <OpenSCAD_Libs/oled_096.scad>

/* [Box dimensions] */
Length        = 100; // Length 
Width         = 64;  // Width
Height        = 42;  // Height  
Thick         = 3;   // Wall thickness [2:5]  
  
/* [Box options] */
Vent          = 0;   // Decorations to ventilation holes [0:No, 1:Yes]
Vent_width    = 1.5; // Holes width (in mm)  
txt           = "HeartyGFX"; // Text you want
TxtSize       = 3;   // Font size  
Police        ="Arial Black"; // Font
Filet         = 2;   // Filet diameter [0.1:12] 
Resolution    = 50;  // Filet smoothness [1:100] 
m             = 0.9; // Tolerance (Panel/rails gap)

/* [Display options] */
OledPosX = Length-7;
OledPosY = Width/2;
OledPosZ = Height/2;

/* [STL element to export] */
TShell        = 0;   // Top shell [0:No, 1:Yes]
BShell        = 1;   // Bottom shell [0:No, 1:Yes]
BPanel        = 1;   // Back panel [0:No, 1:Yes]
FPanel        = 1;   // Front panel [0:No, 1:Yes]
Text          = 0;   // Front text [0:No, 1:Yes]
Components    = 1;   // Arduino parts [0:No, 1:Yes]
  
/* [Hidden] */
Color1    = "Orange";    // Shell color  
Color2    = "OrangeRed"; // Panels color    
Dec_Thick = Vent ? Thick*2 : Thick; // Thick X 2 - make sure they go through shell
Dec_size  = Vent ? Thick*2 : 0.8; // Depth decoration

/////////// - Generic Fileted box - //////////
module RoundBox($a=Length, $b=Width, $c=Height){// Cube bords arrondis
                    $fn=Resolution;            
                    translate([0,Filet,Filet]){  
                    minkowski (){                                              
                        cube ([$a-(Length/2),$b-(2*Filet),$c-(2*Filet)], center = false);
                        rotate([0,90,0]){    
                        cylinder(r=Filet,h=Length/2, center = false);
                            } 
                        }
                    }
                }// End of RoundBox Module

      
////////////////////////////////// - Module Shell - //////////////////////////////////         
module Shell(){// Shell  
    Thick = Thick*2;  
    difference(){    
        difference(){//sides decoration
            union(){    
                     difference() {// Substraction Fileted box
                      
                        difference(){// Median cube slicer
                            union() {// Union               
                            difference(){//S hell    
                                RoundBox();
                                translate([Thick/2,Thick/2,Thick/2]){     
                                        RoundBox($a=Length-Thick, $b=Width-Thick, $c=Height-Thick);
                                        }
                                        }//Fin diff Shell                            
                                difference(){//largeur Rails        
                                     translate([Thick+m,Thick/2,Thick/2]){// Rails
                                          RoundBox($a=Length-((2*Thick)+(2*m)), $b=Width-Thick, $c=Height-(Thick*2));
                                                          }//fin Rails
                                     translate([((Thick+m/2)*1.55),Thick/2,Thick/2+0.1]){ // +0.1 added to avoid the artefact
                                          RoundBox($a=Length-((Thick*3)+2*m), $b=Width-Thick, $c=Height-Thick);
                                                    }           
                                                }//Fin largeur Rails
                                    }//Fin union                                   
                               translate([-Thick,-Thick,Height/2]){// Cube à soustraire
                                    cube ([Length+100, Width+100, Height], center=false);
                                            }                                            
                                      }//fin soustraction cube median - End Median cube slicer
                               translate([-Thick/2,Thick,Thick]){// Forme de soustraction centrale 
                                    RoundBox($a=Length+Thick, $b=Width-Thick*2, $c=Height-Thick);       
                                    }                          
                                }                                          


                difference(){// Fixation box legs
                    union(){
                        translate([3*Thick +5,Thick,Height/2]){
                            rotate([90,0,0]){
                                    $fn=6;
                                    cylinder(d=16,Thick/2);
                                    }   
                            }
                            
                       translate([Length-((3*Thick)+5),Thick,Height/2]){
                            rotate([90,0,0]){
                                    $fn=6;
                                    cylinder(d=16,Thick/2);
                                    }   
                            }

                        }
                            translate([4,Thick+Filet,Height/2-57]){   
                             rotate([45,0,0]){
                                   cube([Length,40,40]);    
                                  }
                           }
                           translate([0,-(Thick*1.46),Height/2]){
                                cube([Length,Thick*2,10]);
                           }
                    } //Fin fixation box legs
            }

        union(){// outbox sides decorations
            //if(Thick==1){Thick=2;
            for(i=[0:Thick:Length/4]){

                // Ventilation holes part code submitted by Ettie - Thanks ;) 
                    translate([10+i,-Dec_Thick+Dec_size,1]){
                    cube([Vent_width,Dec_Thick,Height/4]);
                    }
                    translate([(Length-10) - i,-Dec_Thick+Dec_size,1]){
                    cube([Vent_width,Dec_Thick,Height/4]);
                    }
                    translate([(Length-10) - i,Width-Dec_size,1]){
                    cube([Vent_width,Dec_Thick,Height/4]);
                    }
                    translate([10+i,Width-Dec_size,1]){
                    cube([Vent_width,Dec_Thick,Height/4]);
                    }
  
                
                    }// fin de for
               // }
                }//fin union decoration
            }//fin difference decoration


            union(){ //sides holes
                $fn=50;
                translate([3*Thick+5,20,Height/2+4]){
                    rotate([90,0,0]){
                    cylinder(d=2,20);
                    }
                }
                translate([Length-((3*Thick)+5),20,Height/2+4]){
                    rotate([90,0,0]){
                    cylinder(d=2,20);
                    }
                }
                translate([3*Thick+5,Width+5,Height/2-4]){
                    rotate([90,0,0]){
                    cylinder(d=2,20);
                    }
                }
                translate([Length-((3*Thick)+5),Width+5,Height/2-4]){
                    rotate([90,0,0]){
                    cylinder(d=2,20);
                    }
                }
            }//fin de sides holes

        }//fin de difference holes
}// fin Shell 

///////////////////////////////// - Module Front/Back Panels - //////////////////////////
module Panels(){// Panels
    color(Color2){
        translate([Thick+m,m/2,m/2]){
             difference(){
                  translate([0,Thick,Thick]){ 
                     RoundBox(Length,Width-((Thick*2)+m),Height-((Thick*2)+m));}
                  translate([Thick,-5,0]){
                     cube([Length,Width+10,Height]);}
                     }
                }
         }
}


///////////////////////////////////// - Main - ///////////////////////////////////////

//Back Panel
if(BPanel==1)
translate ([-m/2,0,0]){
    Panels();
}

//Front Panel
if(FPanel==1) {
    difference() {
        rotate([0,0,180]){
            translate([-Length-m/2,-Width,0]){
                Panels();
            }
        }
        // OLED cutout
        translate([OledPosX, OledPosY, OledPosZ])
            rotate([90,0,90])
                oled_cutout();
    }

    // OLED posts
    translate([OledPosX, OledPosY, OledPosZ])
        rotate([90,0,90])
            oled_posts();
 
    // OLED
    translate([OledPosX, OledPosY, OledPosZ])
        rotate([90,0,90])
            DisplayModule(type=I2C4, align=1, G_COLORS=true);
}

// Front text
if(Text==1)
color(Color1){     
     translate([Length-(Thick),Thick*4,(Height-(Thick*4+(TxtSize/2)))]){// x,y,z
          rotate([90,0,90]){
              linear_extrude(height = 0.25){
              text(txt, font = Police, size = TxtSize,  valign ="center", halign ="left");
                        }
                 }
         }
}

// Bottom shell
if(BShell==1)
color(Color1){ 
	Shell();
}

// Top Shell
if(TShell==1)
color(Color1,1){
    translate([0,Width,Height+0.2]){
        rotate([0,180,180]){
                Shell();
                }
        }
}

if(Components==1){
	// Nano
	translate([5, 6, Thick/2]) {
		%nano();
		nano_mount();
    }

	// HX711
	translate([5, 36, Thick/2]) {
		%hx711();
		hx711_mount();
    }

	// Battery
	translate([56, 6, Thick/2])
	rotate([90,270,180]) %9V();
}

