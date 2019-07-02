
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
    PreScan(); %Some bugs in this function!!! "Error using eval
% Undefined function or variable 'GradLinear'.
% 
% Error in Grad_LinearHead (line 17)
% eval([p.GradLine '=' 'GradLinear(p);'])
% 
% Error in PreScan (line 78)
%     eval(['[GxR,GyPE,GzSS]=' name ';']);"
    Scan(T2StarValue);
end