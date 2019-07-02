
function ExecFlag=ImgRecon(Simuh)

global VCtl;
global VImg;

ExecFlag = 1;
TmpVImg = VImg;
    VImg = []; % clear VImg
    % normal Cartesian
    CartRecon();
               
    %%  Saving output
    DoSaveOutput(Simuh);
    


end