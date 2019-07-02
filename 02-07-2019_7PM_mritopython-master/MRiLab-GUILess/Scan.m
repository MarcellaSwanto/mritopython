function img2_scanned = Scan(T2StarValue)
global VObj;
global VCtl;
global VMag;
global VCoi;
global VVar;
global VSig;

global VMmg;
global VMco;
global VMgd;

% try
    % Preserve VObj VMag
    VTmpObj=VObj;
    VTmpMag=VMag;
    
    % Create Executing Virtual Structure VOex VMex
    VOex=VObj;
    VOex.Rho(repmat(VMag.FRange,  [1,1,1,VObj.TypeNum])==0)=[];
    VOex.T1(repmat(VMag.FRange,[1,1,1,VObj.TypeNum])==0)=[];
    VOex.T2(repmat(VMag.FRange,[1,1,1,VObj.TypeNum])==0)=[];
    VOex.Mz(repmat(VMag.FRange,[1,1,1,VObj.SpinNum,VObj.TypeNum])==0)=[];
    VOex.My(repmat(VMag.FRange,[1,1,1,VObj.SpinNum,VObj.TypeNum])==0)=[];
    VOex.Mx(repmat(VMag.FRange,[1,1,1,VObj.SpinNum,VObj.TypeNum])==0)=[];
    
    VMex=VMag;
    VMex.Gzgrid(VMag.FRange==0)=[];
    VMex.Gygrid(VMag.FRange==0)=[];
    VMex.Gxgrid(VMag.FRange==0)=[];
    VMex.dB0(VMag.FRange==0)=[];
    VMex.dWRnd(repmat(VMag.FRange,[1,1,1,VObj.SpinNum,VObj.TypeNum])==0)=[];
    VMex.dWRnd(isnan(VMex.dWRnd))=0; % NaN is not supported in C code
    
    % Kernel uses Mz to determine SpinMx size
    VOex.Rho=reshape(VOex.Rho,[max(max(sum(VMag.FRange,1))),max(max(sum(VMag.FRange,2))),max(max(sum(VMag.FRange,3))),VObj.TypeNum]);
    VOex.T1=reshape(VOex.T1,[max(max(sum(VMag.FRange,1))),max(max(sum(VMag.FRange,2))),max(max(sum(VMag.FRange,3))),VObj.TypeNum]);
    VOex.T2=reshape(VOex.T2,[max(max(sum(VMag.FRange,1))),max(max(sum(VMag.FRange,2))),max(max(sum(VMag.FRange,3))),VObj.TypeNum]);
    VOex.Mz=reshape(VOex.Mz,[max(max(sum(VMag.FRange,1))),max(max(sum(VMag.FRange,2))),max(max(sum(VMag.FRange,3))),VObj.SpinNum,VObj.TypeNum]);
    VOex.Mx=reshape(VOex.Mx,[max(max(sum(VMag.FRange,1))),max(max(sum(VMag.FRange,2))),max(max(sum(VMag.FRange,3))),VObj.SpinNum,VObj.TypeNum]);
    VOex.My=reshape(VOex.My,[max(max(sum(VMag.FRange,1))),max(max(sum(VMag.FRange,2))),max(max(sum(VMag.FRange,3))),VObj.SpinNum,VObj.TypeNum]);

    
    VMex.Gzgrid=reshape(VMex.Gzgrid,[max(max(sum(VMag.FRange,1))),max(max(sum(VMag.FRange,2))),max(max(sum(VMag.FRange,3)))]);
    VMex.Gxgrid=reshape(VMex.Gxgrid,[max(max(sum(VMag.FRange,1))),max(max(sum(VMag.FRange,2))),max(max(sum(VMag.FRange,3)))]);
    VMex.Gygrid=reshape(VMex.Gygrid,[max(max(sum(VMag.FRange,1))),max(max(sum(VMag.FRange,2))),max(max(sum(VMag.FRange,3)))]);
    VMex.dB0=reshape(VMex.dB0,[max(max(sum(VMag.FRange,1))),max(max(sum(VMag.FRange,2))),max(max(sum(VMag.FRange,3)))]);
    VMex.dWRnd=reshape(VMex.dWRnd,[max(max(sum(VMag.FRange,1))),max(max(sum(VMag.FRange,2))),max(max(sum(VMag.FRange,3))),VObj.SpinNum,VObj.TypeNum]);
    
    [row,col,layer]=size(VOex.Mz);
    VVar.ObjLoc = [((col+1)/2)*VOex.XDimRes; ((row+1)/2)*VOex.YDimRes ; ((layer+1)/2)*VOex.ZDimRes]; % Set matrix center as Object position for motion simulation
    VVar.ObjTurnLoc = [((col+1)/2)*VOex.XDimRes; ((row+1)/2)*VOex.YDimRes ; ((layer+1)/2)*VOex.ZDimRes]; % Set matrix center as Object origin for motion simulation
    
    VOex.MaxMz = max(VOex.Mz(:));
    VOex.MaxMy = max(VOex.My(:));
    VOex.MaxMx = max(VOex.Mx(:));
    VOex.MaxRho = max(VOex.Rho(:));
    VOex.MaxT1 = max(VOex.T1(:));
    VOex.MaxT2 = max(VOex.T2(:));
    VOex.MaxdWRnd = max(VMex.dWRnd(:));
    
    % Spin execution
    VObj=VOex;
    VMag=VMex;
    
    % Scan Process
    PulseGen(); % Generate Pulse line - fixed the bugs here on 01/07/2019. 
    VCtl.RunMode=int32(0); % Image scan
    DoDataTypeConv(1); %Stopped here on 01/07/2019 - wasn't able to fix the bugs here.
                        %01-07-2019 - Commented out any VMot related stuff.
                        %It now goes until DOScanAtCPU.cpp
    
    VCtl.MaxThreadNum=8;
    VCtl.ActiveThreadNum=int32(0);
    
    DoScanAtCPU;  % global (VSeq,VObj,VCtl,VMag,VCoi,VVar,VSig) are needed

    DoPostScan();
% catch me
%     if handles.BatchFlag==1 & strcmp(me.message(1:2),'Do')
%         if ~isfield(VCtl,'SeriesName')
%             error_msg{1,1}='ERROR!!! No MR sequence is loaded!';
%             errordlg(error_msg);
%         else
%             set(hObject,'String','+Batch');
%             handles.Engine=me.message;
%             handles.SimName=VCtl.SeriesName;
% 
%             DoUpdateBatch(handles);
%             
%             handles=guidata(handles.SimuPanel_figure);
%             handles.BatchFlag=0;
%             DoScanSeriesUpd(handles,5);
%             handles=guidata(handles.SimuPanel_figure);
%             DoScanSeriesUpd(handles,0);
%             
%             str = get(handles.Batch_pushbutton,'String');
%             set(handles.Batch_pushbutton,'String',['\_' num2str(str2num(str(3:end-2))+1) '_/']);
%             
%         end
%     else
%         error_msg{1,1}='ERROR!!! Scan process aborted.';
%         error_msg{2,1}=me.message;
%         errordlg(error_msg);
%         DoScanSeriesUpd(handles,4);
%         handles=guidata(handles.SimuPanel_figure);
%         DoScanSeriesUpd(handles,0);
%     end
% end

% Recover VObj VMag VCoi
VObj=VTmpObj;
VMag=VTmpMag;

end

