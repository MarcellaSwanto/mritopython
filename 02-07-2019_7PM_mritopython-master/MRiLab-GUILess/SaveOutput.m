
function SaveOutput()

global VImg;
global VCtl;
global VSig;

OutputDir='D:\_UNI\2k19\_UROP\guiless\mritopython-master\MRiLab-GUILess\output';

fields = {'Mx','My','Mz','Muts','SignalNum'};
VSig = rmfield(VSig,fields);

if ~verLessThan('matlab','8.5')
    % Code to run in MATLAB R2015a and later here
    fields = {'h'};
    VCtl = rmfield(VCtl,fields);
end

%The code below saves as both mat and ismrmrd files - can change to only
%have 1 later.
%     save([OutputDir filesep 'Series' num2str(Simuh.ScanSeriesInd)], 'VCtl', 'VSig', 'VImg');
%     save([OutputDir filesep 'Series' num2str(Simuh.ScanSeriesInd)], '-struct', 'Simuh', '*XMLFile', '-append');
%     SeriesName = VCtl.SeriesName;
%     save([OutputDir filesep 'Series' num2str(Simuh.ScanSeriesInd)], 'SeriesName', '-append');
    save([OutputDir filesep 'Series1' ], 'VCtl', 'VSig', 'VImg');
    save([OutputDir filesep 'Series1' ], '-struct', 'Simuh', '*XMLFile', '-append');
    SeriesName = VCtl.SeriesName;
    save([OutputDir filesep 'Series1' ], 'SeriesName', '-append');
    try
%         DoToHDF5(Simuh);
    catch me
        error_msg{1,1}='ERROR!!! Saving HDF5 file failed. Mat file was saved. Make sure you have ISMRMRD configured.';
        error_msg{2,1}=me.message;
        errordlg(error_msg);
    end
    

end