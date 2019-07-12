#Need numpy : pip install numpy
#Need LoadImage, VObj in it

# from LoadImage import VObj
import array
import numpy as np

#   VCtl
#These are the calculations
#   VCtl.ResFreq = VCtl.ResFreq + ~mod(VCtl.ResFreq,2) % guarantee odd number of Kx sample points for sampling echo peak when Kx = 0
#   VCtl.RFreq=VCtl.FOVFreq/(VCtl.ResFreq - 1);
#   VCtl.ResPhase = VCtl.ResPhase - mod(VCtl.ResPhase,2); % guarantee even number of Ky sample points for Ky = 0
#   VCtl.RPhase=VCtl.FOVPhase/VCtl.ResPhase;
#   VCtl.SliceNum = max(1,VCtl.SliceNum - mod(VCtl.SliceNum,2)); % guarantee even number of Kz sample points for Kz = 0
#   VCtl.RSlice=VCtl.SliceThick;
#   VCtl.FOVSlice=VCtl.SliceNum*VCtl.SliceThick;
#   VCtl.TrajType='cartesian';
#   VCtl.FirstPhNum = VCtl.ResPhase;
#   VCtl.SecondPhNum = VCtl.SliceNum;
#   Simuh.ISO = each dimension (Simuh.ISO's) *2 - 2

#How to make VCtlglobal? if not : array?
VCtl ={
    "ResFreq": 101,
    "RFreq": 0.002,
    "ResPhase": 80,
    "RPhase": 0.0025,
    "SliceNum": 1,
    "RSlice": 0.006,
    "FOVSlice": 0.006,
    "TrajType": "cartesian",
    "FirstPhNum": 80,
    "SecondPhNum": 1,
    "FlipAng": 90, # degree
    "TEAnchorTime": 0,
    "SpinNum": 1,
    "TRNum": 80,
    "FreqDir": "A/P",
    #to be changed for custom phantoms :
    "ISO": [46, 55, 46], #ISO is a List
    "CS": 0,# =ChemShift*VCtl.B0
}
#MxDims=size(VObj.Rho)
Mxdims=np.array([90, 108, 90]) #by default is a row matrix

#Needed for VMag :
VObj ={
#all hardcoded
    "SpinNum" : 1,
    "TypeNum" : 1,
    "XDimRes" : 0.002,
    "YDimRes" : 0.002,
    "ZDimRes" : 0.002,
    "XDim" : 90,
    "YDim" : 108,
    "ZDim" : 90,
}
#VMag Virtual Magnetic Field
VMag ={
#Syntax: np.ones(number of pages, rows, cols)
    "FRange": np.ones((Mxdims[0], Mxdims[1], Mxdims[2])),
    "dB0" : np.zeros((Mxdims[0], Mxdims[1], Mxdims[2])),
    "dWRnd" : np.zeros((Mxdims[0], Mxdims[1], Mxdims[2], VObj["SpinNum"], VObj["TypeNum"])),
    "Gzgrid" : np.zeros((Mxdims[0], Mxdims[1], Mxdims[2])),
    "Gygrid" : np.zeros((Mxdims[0], Mxdims[1], Mxdims[2])),
    "Gxgrid" : np.zeros((Mxdims[0], Mxdims[1], Mxdims[2])),
}

#Gradient Grid
ISO=VCtl["ISO"]

a=(-ISO[0]+1)*VObj["XDimRes"]
b=(VObj["XDim"]-ISO[0])*VObj["XDimRes"]
c=VObj["XDimRes"]
#arange is used because some parameters are floats and not ints. Range only takes in integers
Gxgrid, Gygrid, Gzgrid = np.meshgrid(np.arange(a, b, c ),
np.arange((-ISO[1]+1)*VObj["YDimRes"], (VObj["YDim"]-ISO[1])*VObj["YDimRes"], VObj["YDimRes"]),\
np.arange((-ISO[2]+1)*VObj["ZDimRes"], (VObj["ZDim"]-ISO[2])*VObj["ZDimRes"], VObj["ZDimRes"]))

AP1=5
AP2=105

LR1 = 6
LR2 = 86

SI1 = 45
SI2 = 48
# The scan process parameter for FreqDir is A/P, which corresponds to the
# axial view. (Anterior-Posterior)
# The NoFreqAlias, NoPhaseAlias, NoSliceAlias fields of VCtl have not yet
# been created.
VMag["Gxgrid"]=Gygrid
VMag["Gygrid"]=Gxgrid
VMag["Gzgrid"]=Gzgrid

FRange = VMag["FRange"]
FRange[range(0, AP1-1), :, :]=0
#indexing differences in Python vs Matlab
#python :  range(start, end) does not include end
#So add 1 to ZDim, YDim??? I get an error for Y and Z, not for X.
FRange[range(AP2,VObj["XDim"]), :, :]=0

FRange[:, range(0, LR1-1) ,:]=0
FRange[:, range(LR2,VObj["YDim"]) ,:]=0

FRange[:, :, range(0,SI1-1)]=0
FRange[:, :, range(SI2,VObj["ZDim"])]=0

VObj["Mx"] = np.zeros((Mxdims[0], Mxdims[1], Mxdims[2], VObj["SpinNum"], VObj["TypeNum"]))
VObj["My"] = np.zeros((Mxdims[0], Mxdims[1], Mxdims[2], VObj["SpinNum"], VObj["TypeNum"]))
VObj["Mz"] = np.zeros((Mxdims[0], Mxdims[1], Mxdims[2], VObj["SpinNum"], VObj["TypeNum"]))

VObj_Mz=VObj["Mz"]
VObj_Rho=VObj["Rho"]
for i in range(VObj["TypeNum"]):
    VObj_Mz[:,:,:,:,i]=np.tile(double(VObj_Rho[:,:,:,i])/double(VObj["SpinNum"]) , [1,1,1,VObj["SpinNum"]])

#VSig Virtual Signal
VSig ={
    "Mx": VObj["Mx"],
    "My": VObj["My"],
    "Mz": VObj["Mz"],
    "Muts" : 0,
}

 #    VCoi Virtual Coils
 # B1Level: linear scale factor for B1. The input B1+ field with magnitude of this number produces nominal flip angle
 # E1Level: linear scale factor for E1. The input E1+ field is scaled by an factor of nominal rf amplitude normalzed by this number
VCoi ={
    'TxCoilNum': 1,
    'RxCoilNum': 1,
    'TxCoilDefault': 1, #use default Tx Coil
    'RxCoilDefault': 1, #% use default Rx Coil
    'TxCoilmg': np.ones((Mxdims[0], Mxdims[1], Mxdims[2])),
    'TxCoilpe': np.zeros((Mxdims[0], Mxdims[1], Mxdims[2])),
    'RxCoilx': np.ones((Mxdims[0], Mxdims[1], Mxdims[2])),
    'RxCoily': np.zeros((Mxdims[0], Mxdims[1], Mxdims[2])),
    'TxE1x': 0,
    'TxE1y': 0,
    'TxE1z': 0,
    'RxE1x': 0,
    'RxE1y': 0,
    'RxE1z': 0,
}

# VMot Virtual Motion
VMot={
    't': 0,
    'ind': 1,
    'Disp': np.array([[0],[0],[0]]),
    'Axis': np.array([[1],[0],[0]]),
    'Ang': 0,
}

# VVar Virtual Pulse Packet Initialization
VVar={
    'rfAmp': np.zeros((VCoi["TxCoilNum"], 1)),
    'rfPhase': np.zeros((VCoi["TxCoilNum"], 1)),
    'rfFreq': np.zeros((VCoi["TxCoilNum"], 1)),
    'rfCoil': 0,
    'rfRef': 0,
    'GzAmp': 0,
    'GyAmp': 0,
    'GxAmp': 0,
    'ADC': 0,
    'Ext': 0,
    't': 0,
    'dt': 0,
    'rfi': 0,
    'Gzi': 0,
    'Gyi': 0,
    'Gxi': 0,
    'ADCi': 0,
    'Exti': 0,
    'utsi': 0,
    'Kz': 0,
    'Ky': 0,
    'Kx': 0,
    'SliceCount': 0,
    'PhaseCount': 0,
    'TRCount': 0,
    'ObjLoc': np.array([[0],[0],[0]]),  # Object location
    'ObjTurnLoc': np.array([[0],[0],[0]]),  # Object turning point location
    'ObjAng': 0,  # Object rotating angle
    'ObjMotInd': 0,  # Object motion section index
    'gpuFetch': 0,  # Flag for fetching GPU data at extended process
}
