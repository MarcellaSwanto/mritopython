% This script requires the BrainStandardResolution.mat
% file to be in the current directory. This demo only 
% saves 3 different fields: T1,T2 and Rho. Not sure
% which other ones should be saved for the simulator...
%Have now included MassDen and T2Star
load BrainStandardResolution.mat;

% Get the size of the phantoms
PhantDims = size(VObj.Rho);

if exist('myfile.h5','file') 
    delete('myfile.h5');
end;

fid = H5F.create('myfile.h5');

% Note the pattern below... add more "creates" for each property
% the "fliplr" deals with Matlab's odd ordering of dimensions
% This seems a strange way to calculate end reserve space
% for the data in local memory (not in the file itself)
% Might *actually* be done for disk buffering; these
% IDs appear to be pointers...
Rho_id = H5S.create_simple(length(PhantDims),fliplr(PhantDims),[]);
T1_id = H5S.create_simple(length(PhantDims),fliplr(PhantDims),[]);
T2_id = H5S.create_simple(length(PhantDims),fliplr(PhantDims),[]);
T2Star_id = H5S.create_simple(length(PhantDims),fliplr(PhantDims),[]);
% ECon_id = H5S.create_simple(length(PhantDims),fliplr(PhantDims),[]);
MassDen_id = H5S.create_simple(length(PhantDims),fliplr(PhantDims),[]);
% Next few lines actually seem to reserve locations in
% the file to write *information* about the data,
% like its name and type.
dcpl = 'H5P_DEFAULT'; % No idea what this does...used consistently below
dset_id_rho = H5D.create(fid,'Rho','H5T_NATIVE_DOUBLE',Rho_id,dcpl);
dset_id_T1 = H5D.create(fid,'T1','H5T_NATIVE_DOUBLE',T1_id,dcpl);
dset_id_T2 = H5D.create(fid,'T2','H5T_NATIVE_DOUBLE',T2_id,dcpl);
dset_id_T2Star = H5D.create(fid,'T2Star','H5T_NATIVE_DOUBLE',T2Star_id,dcpl);
% dset_id_ECon = H5D.create(fid,'ECon','H5T_NATIVE_DOUBLE',ECon_id,dcpl);
dset_id_MassDen = H5D.create(fid,'MassDen','H5T_NATIVE_DOUBLE',MassDen_id,dcpl);
% Create the "slots" in the file for the data. I guess
% having separate handles in this way to the locations
% on disk within the file (like these ideas below) will
% allow multiple write processes to happen at the same
% time - this is probably why this sort of structure 
% to H5 exists!
file_space_id_rho = H5D.get_space(dset_id_rho);
file_space_id_T1 = H5D.get_space(dset_id_T1);
file_space_id_T2 = H5D.get_space(dset_id_T2);
file_space_id_T2Star = H5D.get_space(dset_id_T2Star);
% file_space_id_ECon = H5D.get_space(dset_id_ECon);
file_space_id_MassDen = H5D.get_space(dset_id_MassDen);
% Do the *actual* writing
H5D.write(dset_id_rho,'H5ML_DEFAULT',Rho_id,file_space_id_rho,'H5P_DEFAULT',VObj.Rho);
H5D.write(dset_id_T1,'H5ML_DEFAULT',T1_id,file_space_id_T1,'H5P_DEFAULT',VObj.T1);
H5D.write(dset_id_T2,'H5ML_DEFAULT',T2_id,file_space_id_T2,'H5P_DEFAULT',VObj.T2);
H5D.write(dset_id_T2Star,'H5ML_DEFAULT',T2Star_id,file_space_id_T2Star,'H5P_DEFAULT',VObj.T2Star);
% H5D.write(dset_id_ECon,'H5ML_DEFAULT',ECon_id,file_space_id_ECon,'H5P_DEFAULT',VObj.ECon);
H5D.write(dset_id_MassDen,'H5ML_DEFAULT',MassDen_id,file_space_id_MassDen,'H5P_DEFAULT',VObj.MassDen);
% Delete the pointers to 
H5S.close(Rho_id);
H5S.close(T1_id);
H5S.close(T2_id);
H5S.close(T2Star_id);
% H5S.close(ECon_id);
H5S.close(MassDen_id);

H5D.close(dset_id_rho);
H5D.close(dset_id_T1);
H5D.close(dset_id_T2);
H5D.close(dset_id_T2Star);
% H5D.close(dset_id_ECon);
H5D.close(dset_id_MassDen);
% Close the file itself
H5F.close(fid);


