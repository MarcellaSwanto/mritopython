import Plugin_ResetK
#Where to import stuff from? Scan.py? Or .cpp file?
#  If importing from Scan:
#from Scan import VVar
#from Scan import VObj
#from Scan import VMag
#from Scan import VCoi
#from Scan import VCtl

#entry function for extended plugin based on Ext flag
Plugin_ResetK=Plugin_ResetK.Plugin_ResetK()

VObj["Mz"]=float(VObj["Mz"])
VObj["My"]=float(VObj["My"])
VObj["Mx"]=float(VObj["Mx"])
VObj["Mz"]=float(VObj["Mz"])
VObj["Rho"]=float(VObj["Rho"])
VObj["T1"]=float(VObj["T1"])
VObj["T2"]=float(VObj["T2"])

VMag["dB0"]=float(VMag["dB0"])
VMag["dWRnd"]=float(VMag["dWRnd"])
VMag["Gzgrid"]=float(VMag["Gzgrid"])
VMag["Gygrid"]=float(VMag["Gygrid"])
VMag["Gxgrid"]=float(VMag["Gxgrid"])

VCoi["TxCoilmg"]=float(VCoi["TxCoilmg"])
VCoi["TxCoilpe"]=float(VCoi["TxCoilpe"])
VCoi["RxCoilx"]=float(VCoi["RxCoilx"]
VCoi["RxCoily"]=float(VCoi["Coily"])
