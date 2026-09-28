%-----------------------------------------------------------------------
% Job saved on 26-Jan-2026 00:35:22 by cfg_util (rev $Rev: 7345 $)
% spm SPM - SPM12 (7771)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
matlabbatch{1}.spm.tools.oldnorm.write.subj.matname = {'C:\Users\andrew\Desktop\00699079\00699079_DWI_seg_sn.mat'};
matlabbatch{1}.spm.tools.oldnorm.write.subj.resample = {'C:\Users\andrew\Desktop\00699079\00699079_DWI.nii,1'};
matlabbatch{1}.spm.tools.oldnorm.write.roptions.preserve = 0;
matlabbatch{1}.spm.tools.oldnorm.write.roptions.bb = [NaN NaN NaN
                                                      NaN NaN NaN];
matlabbatch{1}.spm.tools.oldnorm.write.roptions.vox = [1 1 1];
matlabbatch{1}.spm.tools.oldnorm.write.roptions.interp = 1;
matlabbatch{1}.spm.tools.oldnorm.write.roptions.wrap = [0 0 0];
matlabbatch{1}.spm.tools.oldnorm.write.roptions.prefix = 'w';

save('normalize_job.mat','matlabbatch')
