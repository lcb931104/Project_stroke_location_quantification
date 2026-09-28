% List of open inputs
nrun = X; % enter the number of runs here
jobfile = {'C:\Users\User\Desktop\專題 分割方法\normalize_job.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(0, nrun);
for crun = 1:nrun
end
spm('defaults', 'FMRI');
spm_jobman('run', jobs, inputs{:});
