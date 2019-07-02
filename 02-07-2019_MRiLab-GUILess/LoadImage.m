function VObjSpinMap = LoadImage()
    %Global Variables
    global VObj; VObj=[];
    global VCtl; VCtl=[];
    global VMag; VMag=[];
    global VCoi; VCoi=[];
    global VVar; VVar=[];

    %Load the .mat file and extract the variables.
    load BrainStandardResolution.mat
    VObjPro=fieldnames(VObj);
    VObjSpinMapind=1;
    %Store the necessary fieldnames in a new array.
    for i=1:length(VObjPro)
        d=size(VObj.(VObjPro{i}));
        if numel(d)==2
            if d(1)==1 & d(2)==1
                % do nothing for one point
            elseif d(1)==1 | d(2)==1
                % do nothing for one line
            elseif d(1)~=0 & d(2)~=0
                VObjSpinMap(VObjSpinMapind,1)=VObjPro(i);
                VObjSpinMapind=VObjSpinMapind+1;
            end
        elseif numel(d)==3 | numel(d)==4
            VObjSpinMap(VObjSpinMapind,1)=VObjPro(i);
            VObjSpinMapind=VObjSpinMapind+1;
        end
    end
end