function PreScan()

global VObj;
global VCtl;
global VMag;
global VCoi;
global VVar;
global VSig;

global VMmg;
global VMco;
global VMgd;

VCtl=[]; % update VCtl

% FOV & resolution
  % Cartesian
    VCtl.ResFreq = 100;
    VCtl.RFreq=0.002;
    VCtl.ResPhase = 80; % guarantee even number of Ky sample points for Ky = 0
    VCtl.RPhase=0.0025;
    VCtl.SliceNum = 1; % guarantee even number of Kz sample points for Kz = 0
    VCtl.RSlice=0.006;
    VCtl.FOVSlice=0.006;
    VCtl.TrajType='cartesian';
    VCtl.FirstPhNum = 80;
    VCtl.SecondPhNum = 1;
    %These are the calculations
%   VCtl.ResFreq = VCtl.ResFreq + ~mod(VCtl.ResFreq,2) % guarantee odd number of Kx sample points for sampling echo peak when Kx = 0
%   VCtl.RFreq=VCtl.FOVFreq/(VCtl.ResFreq - 1);
%   VCtl.ResPhase = VCtl.ResPhase - mod(VCtl.ResPhase,2); % guarantee even number of Ky sample points for Ky = 0
%   VCtl.RPhase=VCtl.FOVPhase/VCtl.ResPhase;
%   VCtl.SliceNum = max(1,VCtl.SliceNum - mod(VCtl.SliceNum,2)); % guarantee even number of Kz sample points for Kz = 0
%   VCtl.RSlice=VCtl.SliceThick;
%   VCtl.FOVSlice=VCtl.SliceNum*VCtl.SliceThick;
%   VCtl.TrajType='cartesian';
%   VCtl.FirstPhNum = VCtl.ResPhase;
%   VCtl.SecondPhNum = VCtl.SliceNum;
% Others
VCtl.FlipAng=90; % degree
VCtl.TEAnchorTime=0;
%Simuh.ISO = each dimension (Simuh.ISO's) *2 - 2
VCtl.ISO=[46 55 46];
VCtl.CS=0;%VObj.ChemShift*VCtl.B0;
VObj.SpinNum=1; % Controllable Spin number in each voxel
                                % Transfer VCtl to VObj, should have better
                                % way to do this ??


VCtl.TRNum=VCtl.FirstPhNum*VCtl.SecondPhNum;
VCtl.FreqDir='A/P';

%% VMag Virtual Magnetic Field
Mxdims=size(VObj.Rho);
if numel(Mxdims)==2
    if Mxdims(1)==1 | Mxdims(2)==1
        Mxdims(1)=1;
        Mxdims(2)=1;
        Mxdims(3)=1;
    end
end
VMag=struct(                                      ...
           'FRange',    ones([Mxdims(1), Mxdims(2), Mxdims(3)]), ...
           'dB0',       zeros([Mxdims(1), Mxdims(2), Mxdims(3)]),    ...
           'dWRnd',     zeros([Mxdims(1), Mxdims(2), Mxdims(3), VObj.SpinNum, VObj.TypeNum]), ...
           'Gzgrid',    zeros([Mxdims(1), Mxdims(2), Mxdims(3)]), ...
           'Gygrid',    zeros([Mxdims(1), Mxdims(2), Mxdims(3)]), ...
           'Gxgrid',    zeros([Mxdims(1), Mxdims(2), Mxdims(3)]) ...
          );

% Gradient Grid             

    [VMgd.xgrid,VMgd.ygrid,VMgd.zgrid]=meshgrid((-VCtl.ISO(1)+1)*VObj.XDimRes:VObj.XDimRes:(VObj.XDim-VCtl.ISO(1))*VObj.XDimRes,...
                                                (-VCtl.ISO(2)+1)*VObj.YDimRes:VObj.YDimRes:(VObj.YDim-VCtl.ISO(2))*VObj.YDimRes,...
                                                (-VCtl.ISO(3)+1)*VObj.ZDimRes:VObj.ZDimRes:(VObj.ZDim-VCtl.ISO(3))*VObj.ZDimRes); 
    
    [pathstr,name,ext]=fileparts('C:\MRiLab-GUILess\Grad_LinearHead.XML');
    eval(['[GxR,GyPE,GzSS]=' name ';']);
    
    % Calculate G*grid based on gradient profile, gradient integral
    if isempty(find(GxR ~=0, 1))
        Gxgrid = VMgd.xgrid;
    else
        TmpGxR=GxR(:,:,:,1);
        TmpGxR(VMgd.xgrid<=0) = 0;
        Gxgrid = cumsum(TmpGxR,2) .* VObj.XDimRes;
        TmpGxR=GxR(:,:,:,1);
        TmpGxR(VMgd.xgrid>=0) = 0;
        Gxgrid = Gxgrid + flipdim(cumsum(flipdim(-TmpGxR,2),2),2) .* VObj.XDimRes;
        
        TmpGxR=GxR(:,:,:,2);
        TmpGxR(VMgd.ygrid<=0) = 0;
        Gxgrid = Gxgrid + cumsum(TmpGxR,1).* VObj.YDimRes;
        TmpGxR=GxR(:,:,:,2);
        TmpGxR(VMgd.ygrid>=0) = 0;
        Gxgrid = Gxgrid + flipdim(cumsum(flipdim(-TmpGxR,1),1),1) .* VObj.YDimRes;
        
        TmpGxR=GxR(:,:,:,3);
        TmpGxR(VMgd.zgrid<=0) = 0;
        Gxgrid = Gxgrid + cumsum(TmpGxR,3) .* VObj.ZDimRes;
        TmpGxR=GxR(:,:,:,3);
        TmpGxR(VMgd.zgrid>=0) = 0;
        Gxgrid = Gxgrid + flipdim(cumsum(flipdim(-TmpGxR,3),3),3) .* VObj.ZDimRes;
        
    end
    
    if isempty(find(GyPE ~=0, 1))
        Gygrid = VMgd.ygrid;
        
    else
        TmpGyPE=GyPE(:,:,:,1);
        TmpGyPE(VMgd.xgrid<=0) = 0;
        Gygrid = cumsum(TmpGyPE,2) .* VObj.XDimRes;
        TmpGyPE=GyPE(:,:,:,1);
        TmpGyPE(VMgd.xgrid>=0) = 0;
        Gygrid = Gygrid + flipdim(cumsum(flipdim(-TmpGyPE,2),2),2) .* VObj.XDimRes;
        
        TmpGyPE=GyPE(:,:,:,2);
        TmpGyPE(VMgd.ygrid<=0) = 0;
        Gygrid = Gygrid + cumsum(TmpGyPE,1) .* VObj.YDimRes;
        TmpGyPE=GyPE(:,:,:,2);
        TmpGyPE(VMgd.ygrid>=0) = 0;
        Gygrid = Gygrid + flipdim(cumsum(flipdim(-TmpGyPE,1),1),1) .* VObj.YDimRes;
        
        TmpGyPE=GyPE(:,:,:,3);
        TmpGyPE(VMgd.zgrid<=0) = 0;
        Gygrid = Gygrid + cumsum(TmpGyPE,3) .* VObj.ZDimRes;
        TmpGyPE=GyPE(:,:,:,3);
        TmpGyPE(VMgd.zgrid>=0) = 0;
        Gygrid = Gygrid + flipdim(cumsum(flipdim(-TmpGyPE,3),3),3) .* VObj.ZDimRes;
        
    end
    
    if isempty(find(GzSS ~=0, 1))
        Gzgrid = VMgd.zgrid;
        
    else
        TmpGzSS=GzSS(:,:,:,1);
        TmpGzSS(VMgd.xgrid<=0) = 0;
        Gzgrid = cumsum(TmpGzSS,2) .* VObj.XDimRes;
        TmpGzSS=GzSS(:,:,:,1);
        TmpGzSS(VMgd.xgrid>=0) = 0;
        Gzgrid = Gzgrid + flipdim(cumsum(flipdim(-TmpGzSS,2),2),2) .* VObj.XDimRes;
        
        TmpGzSS=GzSS(:,:,:,2);
        TmpGzSS(VMgd.ygrid<=0) = 0;
        Gzgrid = Gzgrid + cumsum(TmpGzSS,1) .* VObj.YDimRes;
        TmpGzSS=GzSS(:,:,:,2);
        TmpGzSS(VMgd.ygrid>=0) = 0;
        Gzgrid = Gzgrid + flipdim(cumsum(flipdim(-TmpGzSS,1),1),1) .* VObj.YDimRes;
        
        TmpGzSS=GzSS(:,:,:,3);
        TmpGzSS(VMgd.zgrid<=0) = 0;
        Gzgrid = Gzgrid + cumsum(TmpGzSS,3) .* VObj.ZDimRes;
        TmpGzSS=GzSS(:,:,:,3);
        TmpGzSS(VMgd.zgrid>=0) = 0;
        Gzgrid = Gzgrid + flipdim(cumsum(flipdim(-TmpGzSS,3),3),3) .* VObj.ZDimRes;
        
    end
AP1=5;
AP2=105;
%The scan process parameter for FreqDir is A/P, which corresponds to the
%Axial view. (Anterior-Posterior)
%The NoFreqAlias, NoPhaseAlias, NoSliceAlias fields of VCtl have not yet
%been created.
     VMag.Gxgrid=Gygrid;
     VMag.Gygrid=Gxgrid;
     VMag.Gzgrid=Gzgrid;
            
     VMag.FRange(1:AP1-1,:,:)=0;
     VMag.FRange(AP2:end,:,:)=0;
if VObj.SpinNum >1
    InddWRnd=linspace(0.01,0.99,VObj.SpinNum);
    for j=1:VObj.TypeNum
        for i=1:VObj.SpinNum
            VMag.dWRnd(:,:,:,i,j)=(1./VObj.T2Star(:,:,:,j)-1./VObj.T2(:,:,:,j)).*tan(pi.*(InddWRnd(i)-1/2));
            % need large number of spins for stimulating T2* effect,
            % insufficient number of spins may cause in-accurate simulation
        end
    end
end

    [VMmg.xgrid,VMmg.ygrid,VMmg.zgrid]=meshgrid((-(Mxdims(2)-1)/2)*VObj.XDimRes:VObj.XDimRes:((Mxdims(2)-1)/2)*VObj.XDimRes,...
                                                (-(Mxdims(1)-1)/2)*VObj.YDimRes:VObj.YDimRes:((Mxdims(1)-1)/2)*VObj.YDimRes,...
                                                (-(Mxdims(3)-1)/2)*VObj.ZDimRes:VObj.ZDimRes:((Mxdims(3)-1)/2)*VObj.ZDimRes);
    [pathstr,name,ext]=fileparts('C:\MRiLab-GUILess\Mag_LinearHead.XML');
    eval(['dB0=' name ';']);
    VMag.dB0=dB0;

%% VObj Virtual Object
VObj.Mx=zeros([Mxdims(1), Mxdims(2), Mxdims(3), VObj.SpinNum, VObj.TypeNum]);
VObj.My=zeros([Mxdims(1), Mxdims(2), Mxdims(3), VObj.SpinNum, VObj.TypeNum]);
VObj.Mz=zeros([Mxdims(1), Mxdims(2), Mxdims(3), VObj.SpinNum, VObj.TypeNum]);
for i=1:VObj.TypeNum
    VObj.Mz(:,:,:,:,i)=repmat(double(VObj.Rho(:,:,:,i))/double(VObj.SpinNum),[1,1,1,VObj.SpinNum]);
end

%% VSig Virtual Signal
VSig.Mx=VObj.Mx;
VSig.My=VObj.My;
VSig.Mz=VObj.Mz;
VSig.Muts=0;

%% VCoi Virtual Coils
% B1Level: linear scale factor for B1. The input B1+ field with magnitude of this number produces nominal flip angle
% E1Level: linear scale factor for E1. The input E1+ field is scaled by an factor of nominal rf amplitude normalzed by this number
VCoi=struct( ...
            'TxCoilNum', 1, ...
            'RxCoilNum', 1, ...
            'TxCoilDefault',1,... % use default Tx Coil
            'RxCoilDefault',1,... % use default Rx Coil
            'TxCoilmg',ones([Mxdims(1), Mxdims(2), Mxdims(3)]), ...
            'TxCoilpe',zeros([Mxdims(1), Mxdims(2), Mxdims(3)]), ...
            'RxCoilx',ones([Mxdims(1), Mxdims(2), Mxdims(3)]), ...
            'RxCoily',zeros([Mxdims(1), Mxdims(2), Mxdims(3)]), ...
            'TxE1x',0,...
            'TxE1y',0,...
            'TxE1z',0,...
            'RxE1x',0,...
            'RxE1y',0,...
            'RxE1z',0 ...
            );
%Transmitter coil code
    [VMco.xgrid,VMco.ygrid,VMco.zgrid]=meshgrid((-(Mxdims(2)-1)/2)*VObj.XDimRes:VObj.XDimRes:((Mxdims(2)-1)/2)*VObj.XDimRes,...
                                                (-(Mxdims(1)-1)/2)*VObj.YDimRes:VObj.YDimRes:((Mxdims(1)-1)/2)*VObj.YDimRes,...
                                                (-(Mxdims(3)-1)/2)*VObj.ZDimRes:VObj.ZDimRes:((Mxdims(3)-1)/2)*VObj.ZDimRes);
    
    VMco.xgrid(repmat(VMag.FRange,[1,1,1,VCoi.RxCoilNum])==0)=[];
    VMco.ygrid(repmat(VMag.FRange,[1,1,1,VCoi.RxCoilNum])==0)=[];
    VMco.zgrid(repmat(VMag.FRange,[1,1,1,VCoi.RxCoilNum])==0)=[];
    VMco.xgrid=reshape(VMco.xgrid,[max(max(sum(VMag.FRange,1))),max(max(sum(VMag.FRange,2))),max(max(sum(VMag.FRange,3))),VCoi.RxCoilNum]);
    VMco.ygrid=reshape(VMco.ygrid,[max(max(sum(VMag.FRange,1))),max(max(sum(VMag.FRange,2))),max(max(sum(VMag.FRange,3))),VCoi.RxCoilNum]);
    VMco.zgrid=reshape(VMco.zgrid,[max(max(sum(VMag.FRange,1))),max(max(sum(VMag.FRange,2))),max(max(sum(VMag.FRange,3))),VCoi.RxCoilNum]);
    
    [pathstr,name,ext]=fileparts('C:\MRiLab-GUILess\Coil_8ChHead.xml');
    eval(['[B1x, B1y, B1z, E1x, E1y, E1z, Pos]=' name ';']);
    VCtl.B1Level = 0.000001; %Hard-coded this value for sequence = PSD_GRE3D, no motion, gradient = linear head, magnet = linear
    %head and coil = 8 ch for both receiver and transmitter    
    VCoi.TxCoilmg=abs(sum(B1x+1i*B1y,4))./VCtl.B1Level; % total B+ field magnitude after normalization
    VCoi.TxCoilpe=angle(sum(B1x+1i*B1y,4)); % total B+ field phase
    VCoi.TxCoilNum=1;
    VCtl.E1Level = 0.000001;
    VCoi.TxE1x=sum(E1x,4)./VCtl.E1Level; % E+ field x component after normalization
    VCoi.TxE1y=sum(E1y,4)./VCtl.E1Level; % E+ field y component after normalization
    VCoi.TxE1z=sum(E1z,4)./VCtl.E1Level; % E+ field z component after normalization
    
    VCoi.TxCoilDefault = 0;


%Create an array (empty). The first time somebody selects Tx and a certain
%coil type, make two new entries (xml file and xml file directory) and
%store the values. Same thing for Rx. Afterwards, if somebody switches
%between Tx and Rx, don't add new fieldnames. Instead simply access the
%existing fieldnames and change the values within. 

    [pathstr,name,ext]=fileparts('C:\MRiLab-GUILess\Coil_8ChHead.xml');
    eval(['[B1x, B1y, B1z, E1x, E1y, E1z, Pos]=' name ';']);
    VCoi.RxCoilx=B1x./(1e-6); % B- field x component after normalization
    VCoi.RxCoily=B1y./(1e-6); % B- field y component after normalization
    VCoi.RxCoilNum=length(Pos(:,1));
    VCoi.RxCoilDefault = 0;
    VCoi.RxE1x=E1x./(1e-6); % E- field x component after normalization
    VCoi.RxE1y=E1y./(1e-6); % E- field y component after normalization
    VCoi.RxE1z=E1z./(1e-6); % E- field z component after normalization

%% VVar Virtual Pulse Packet Initialization
VVar=struct(                          ...
    'rfAmp',        zeros(VCoi.TxCoilNum, 1), ...
    'rfPhase',      zeros(VCoi.TxCoilNum, 1), ...
    'rfFreq',       zeros(VCoi.TxCoilNum, 1), ...
    'rfCoil',       0, ...
    'rfRef',        0,              ...
    'GzAmp',        0,              ...
    'GyAmp',        0,              ...
    'GxAmp',        0,              ...
    'ADC',          0,              ...
    'Ext',          0,              ...
    't',            0,              ...
    'dt',           0,              ...
    'rfi',          0,              ...
    'Gzi',          0,              ...
    'Gyi',          0,              ...
    'Gxi',          0,              ...
    'ADCi',         0,              ...
    'Exti',         0,              ...
    'utsi',         0,              ...
    'Kz',           0,              ...
    'Ky',           0,              ...
    'Kx',           0,              ...
    'SliceCount',   0,              ...
    'PhaseCount',   0,              ...
    'TRCount',      0,              ...
    'ObjLoc',       [0;0;0],        ...  % Object location
    'ObjTurnLoc',   [0;0;0],        ...  % Object turning point location
    'ObjAng',       0,              ...  % Object rotating angle
    'ObjMotInd',    0,              ...  % Object motion section index
    'gpuFetch',     0               ...  % Flag for fetching GPU data at extended process 
    );

end



