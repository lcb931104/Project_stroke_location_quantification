% List of open inputs
% Old Segment: Data - cfg_files
nrun = X; % enter the number of runs here
jobfile = {'C:\Users\User\Desktop\專題 分割方法\segment_job.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(1, nrun);
for crun = 1:nrun
    inputs{1, crun} = MATLAB_CODE_TO_FILL_INPUT; % Old Segment: Data - cfg_files
end
spm('defaults', 'FMRI');
spm_jobman('run', jobs, inputs{:});
