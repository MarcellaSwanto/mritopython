
function mriImage = AllInOneGUILess()
    global VObj;
    global VCtl;
    global VMag;
    global VCoi;
    global VVar;
    global VSig;

    global VMmg;
    global VMco;
    global VMgd;


    spinMap = LoadImage(); %This loads the image from the .mat file into the workspace
    %and extracts the necessary variables into an array
    
    T2StarValue = Localizer(spinMap); %This localizes the image.
    PreScan();
    Scan(T2StarValue); %Gives the following error:
%     Reference to non-existent field 'TEPerTR'.
% 
% Error in CartRecon (line 12)
% SX=reshape(VSig.Sx, VCtl.ResFreq * VCtl.TEPerTR,VCtl.ResPhase,VCtl.SliceNum,VCoi.RxCoilNum,VObj.TypeNum); % matlab col priority
% 
% Error in ImgRecon (line 11)
%     CartRecon();
% 
% Error in DoPostScan (line 14)
%     ExecFlag=ImgRecon();
% 
% Error in Scan (line 78)
%     DoPostScan();
% 
% Error in AllInOneGUILess (line 20)
%     Scan(T2StarValue);
end