
function DoPostScan()

global VCtl
global VImg
global VCoi

%% Signal Post-Processing
%  Add noise
AddNoise;

%% Image reconstruction
    %  Do image reconstruction
    ExecFlag=ImgRecon();
    
    % Saving output
    SaveOutput();

end