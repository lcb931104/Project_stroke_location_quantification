%-----------------------------------------------------------------------
% Job saved on 25-Jan-2026 23:17:40 by cfg_util (rev $Rev: 7345 $)
% spm SPM - SPM12 (7771)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
matlabbatch{1}.spm.tools.oldseg.data = '<UNDEFINED>';
matlabbatch{1}.spm.tools.oldseg.output.GM = [0 0 1];
matlabbatch{1}.spm.tools.oldseg.output.WM = [0 0 1];
matlabbatch{1}.spm.tools.oldseg.output.CSF = [0 0 0];
matlabbatch{1}.spm.tools.oldseg.output.biascor = 1;
matlabbatch{1}.spm.tools.oldseg.output.cleanup = 0;
matlabbatch{1}.spm.tools.oldseg.opts.tpm = {
                                            'C:\Program Files\MATLAB\R2025b\toolbox\spm12\toolbox\OldSeg\grey.nii'
                                            'C:\Program Files\MATLAB\R2025b\toolbox\spm12\toolbox\OldSeg\white.nii'
                                            'C:\Program Files\MATLAB\R2025b\toolbox\spm12\toolbox\OldSeg\csf.nii'
                                            };
matlabbatch{1}.spm.tools.oldseg.opts.ngaus = [2
                                              2
                                              2
                                              4];
matlabbatch{1}.spm.tools.oldseg.opts.regtype = 'eastern';
matlabbatch{1}.spm.tools.oldseg.opts.warpreg = 1;
matlabbatch{1}.spm.tools.oldseg.opts.warpco = 25;
matlabbatch{1}.spm.tools.oldseg.opts.biasreg = 0.0001;
matlabbatch{1}.spm.tools.oldseg.opts.biasfwhm = 60;
matlabbatch{1}.spm.tools.oldseg.opts.samp = 3;
matlabbatch{1}.spm.tools.oldseg.opts.msk = {''};

save('segment_job.mat','matlabbatch')