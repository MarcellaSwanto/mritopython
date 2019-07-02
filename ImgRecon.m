
function ExecFlag=DoImgRecon(Simuh)

global VCtl;
global VImg;

ExecFlag = 1;
TmpVImg = VImg;

try
    VImg = []; % clear VImg
    % normal Cartesian
    CartRecon();
               
    
    %%  Saving output
    DoSaveOutput(Simuh);
    


end