%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MRiLab auto generated file: DO NOT EDIT!     %
% Generated by MRiLab "DoWriteXML2m" Generator %
% MRiLab Version 1.3                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [GxR,GyPE,GzSS]=Grad_LinearHead
global VObj;
GxR=zeros(size(VObj.Rho));
GyPE=zeros(size(VObj.Rho));
GzSS=zeros(size(VObj.Rho));
%====================================
AttributeOpt={'GxR','GyPE','GzSS'};
p.GradLine=AttributeOpt{2};
p.GradX=0;
p.GradY=0.5;
p.GradZ=0;
eval([p.GradLine '=' 'GradLinear(p);'])
p=[];
%--------------------
AttributeOpt={'GxR','GyPE','GzSS'};
p.GradLine=AttributeOpt{1};
p.GradX=1;
p.GradY=0;
p.GradZ=0;
eval([p.GradLine '=' 'GradLinear(p);'])
p=[];
%--------------------
AttributeOpt={'GxR','GyPE','GzSS'};
p.GradLine=AttributeOpt{3};
p.GradX=0;
p.GradY=0;
p.GradZ=1;
eval([p.GradLine '=' 'GradLinear(p);'])
p=[];
%--------------------
end
