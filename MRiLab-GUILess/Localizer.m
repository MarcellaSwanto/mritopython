function img1 = Localizer(SpinMap)
global VObj;
SelMx = VObj.(char(SpinMap(4))); %This is T2Star
img1=SelMx(:,:,:,str2double('1'));

end

