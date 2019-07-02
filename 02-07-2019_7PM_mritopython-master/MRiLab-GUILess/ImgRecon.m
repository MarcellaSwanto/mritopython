
function ExecFlag=ImgRecon()

global VCtl;
global VImg;

ExecFlag = 1;
TmpVImg = VImg;
    VImg = []; % clear VImg
    % normal Cartesian
    CartRecon();

end