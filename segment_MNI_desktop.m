clc;clear;close all;

%% 路徑
% python路徑
pyenv("Version", "C:\Users\andrew\anaconda3\envs\nnunet\python.exe");

% predict 路徑
exe = "C:\Users\andrew\anaconda3\envs\nnunet\Scripts\nnUNetv2_predict.exe";

% 模型路徑
setenv("nnUNet_raw", "C:\Users\andrew\Desktop\nnUNet_train\nnUNet_raw");
setenv("nnUNet_preprocessed", "C:\Users\andrew\Desktop\nnUNet_train\nnUNet_preprocessed");
setenv("nnUNet_results", "C:\Users\andrew\Desktop\nnUNet_train\nnUNet_results");
% setenv("CUDA_VISIBLE_DEVICES", "");

% SPM 程式路徑
segment = load('C:\Users\andrew\Desktop\program_test\MNI_way\segment_job.mat');
normalize = load('C:\Users\andrew\Desktop\program_test\MNI_way\normalize_job.mat');
atlas_file = 'C:\Users\andrew\Desktop\program_test\atlas\JHU_MNI_SS_WMPM_Type-II.nii';
JHU = spm_read_vols(spm_vol(atlas_file));

%% 讀圖譜中心體素座標與中心世界座標

V_atlas = spm_vol(atlas_file);

% 圖譜尺寸
atlas_dim = V_atlas.dim(1:3);

% 中心體素座標（SPM/MATLAB 為 1-based）
atlas_center_vox = (atlas_dim + 1) / 2;

% 中心體素對應的世界座標 (mm)
atlas_center_mm = V_atlas.mat * [atlas_center_vox 1]';
atlas_center_mm = atlas_center_mm(1:3);

%% 讀影像
data_path = inputdlg('請輸入檔案路徑');
data_path{1} = strtrim(data_path{1});  

if startsWith(data_path{1}, '"') && endsWith(data_path{1}, '"')
    data_path{1} = data_path{1}(2:end-1);
end

if isempty(data_path)
    return;
end

% 取出影像所在資料夾
[dataDir,~,~] = fileparts(data_path{1});
[path,~,~] = fileparts(data_path{1});


%% 計算 reorient matrix，並存成 SPM 可用的 reorient.mat
V = spm_vol(data_path{1});
img = spm_read_vols(V);

% 前景 mask：背景是 0
mask = (img ~= 0);

if ~any(mask(:))
    error('影像全為 0，無法計算腦部中心');
end

% 找前景 voxel 座標
[x, y, z] = ind2sub(size(mask), find(mask));

% 前景 bounding box 中心
x_center = (min(x) + max(x)) / 2;
y_center = (min(y) + max(y)) / 2;
z_center = (min(z) + max(z)) / 2;

center_vox = [x_center, y_center, z_center];

% voxel -> mm
center_mm = V.mat * [center_vox 1]';
center_mm = center_mm(1:3);

% reorient matrix：把中心移到 (0,0,0)
T = eye(4);
T(1:3,4) = -center_mm;

% SPM Reorient Images 會用「新矩陣 = M * 舊 V.mat」
% 所以這裡存給 SPM 的 reorientation matrix 應該是 M = T
M = T;

% ===== 存成像 SPM Display 一樣可重用的 reorient.mat =====
[out_dir,~,~] = fileparts(V.fname);
save(fullfile(out_dir, 'reorient.mat'), 'M');

fprintf('已存出: %s\n', fullfile(out_dir, 'reorient.mat'));

%% segment
segment_files = dir(fullfile(path,'*seg_sn*'));

if isempty(segment_files)

    mb_seg = segment.matlabbatch;

    imgFiles = data_path;
    mb_seg{1}.spm.tools.oldseg.data = {imgFiles{1}};
    spm('defaults','fmri');
    spm_jobman('initcfg');
    spm_jobman('run', mb_seg);

end


%% 自動分割

% 建資料夾
imageDir = fullfile(dataDir,'image');
resultDir = fullfile(dataDir,'result');

if ~exist(imageDir,'dir')
    mkdir(imageDir);
end

if ~exist(resultDir,'dir')
    mkdir(resultDir);
end

% 轉檔
nii_file = data_path{1};
[dataDir, name, ext] = fileparts(nii_file);
tmpNii = fullfile(imageDir, sprintf('%s%s', name, ext));
copyfile(nii_file, tmpNii);
gzip(tmpNii);
delete(tmpNii);
nii_gz = tmpNii + ".gz";  
new_name = name + "_0000.nii.gz";
new_path = fullfile(imageDir, new_name);
movefile(nii_gz, new_path);
assert(isfile(new_path), "nnU-Net 輸入檔未成功建立：%s", new_path);

% anaconda
inDir  = imageDir;
outDir = resultDir;

cmd = sprintf('cmd /c ""%s" -d 2 -c 3d_fullres -f 1 -tr nnUNetTrainer_300epoch -device cpu -i "%s" -o "%s""', ...
    exe, inDir, outDir);

[status, output] = system(cmd);
disp(status);
disp(output);

model_result = [name '.nii.gz'];
labelDir = fullfile(resultDir , model_result);
gunzip(labelDir);
nozip = [name '.nii'];
labelDir = fullfile(resultDir , nozip);


%% normalize
[pth, ~, ~] = fileparts(data_path{1});
sn = dir(fullfile(pth,'*seg_sn*.mat'));
sn_mat = fullfile(pth, sn(1).name);

mb_nor = normalize.matlabbatch;

mb_nor{1}.spm.tools.oldnorm.write.subj.matname  = {sn_mat};
mb_nor{1}.spm.tools.oldnorm.write.subj.resample = {
    char(labelDir)
    char(data_path{1})
    };

spm('defaults','fmri');
spm_jobman('initcfg');
spm_jobman('run', mb_nor);

%% 對齊圖譜
[path , name , ext] = fileparts(labelDir);
w_label = fullfile(path,['w' name ext]);

[path , name , ext] = fileparts(data_path{1});
w_data = fullfile(path,['w' name ext]);

V_w = spm_vol(w_label);
w_center_vox = (V_w.dim(1:3) + 1) / 2;

M_old = V_w.mat;
M_new = M_old;
M_new(1:3,4) = atlas_center_mm(:) - M_old(1:3,1:3) * w_center_vox(:);

spm_get_space(w_label, M_new);

V_w2 = spm_vol(w_data);
w_center_vox2 = (V_w2.dim(1:3) + 1) / 2;

M_old2 = V_w2.mat;
M_new2 = M_old2;
M_new2(1:3,4) = atlas_center_mm(:) - M_old2(1:3,1:3) * w_center_vox2(:);

spm_get_space(w_data, M_new2);

%% 定位
atlas = {
    'SUPERIOR PARIETAL LOBULE (left)';
    'CINGULATE GYRUS (left)';
    'SUPERIOR FRONTAL GYRUS (left)';
    'MIDDLE FRONTAL GYRUS (left)';
    'INFERIOR FRONTAL GYRUS (left)';
    'PRECENTRAL GYRUS (left)';
    'POSTCENTRAL GYRUS (left)';
    'ANGULAR GYRUS (left)';
    'PRECUNEUS (left)';
    'CUNEUS (left)';
    'LINGUAL GYRUS (left)';
    'FUSIFORM GYRUS (left)';
    'PARAHIPPOCAMPAL GYRUS (left)';
    'SUPERIOR OCCIPITAL GYRUS (left)';
    'INFERIOR OCCIPITAL GYRUS (left)';
    'MIDDLE OCCIPITAL GYRUS (left)';
    'ENTORHINAL AREA (left)';
    'SUPERIOR TEMPORAL GYRUS (left)';
    'INFERIOR TEMPORAL GYRUS (left)';
    'MIDDLE TEMPORAL GYRUS (left)';
    'LATERAL FRONTO-ORBITAL GYRUS (left)';
    'MIDDLE FRONTO-ORBITAL GYRUS (left)';
    'SUPRAMARGINAL GYRUS (left)';
    'GYRUS RECTUS (left)';
    'INSULA (left)';
    'AMYGDALA (left)';
    'HIPPOCAMPUS (left)';
    'CEREBELLUM (left)';
    'CORTICOSPINAL TRACT (left)';
    'INFERIOR CEREBELLAR PEDUNCLE (left)';
    'MEDIAL LEMNISCUS (left)';
    'SUPERIOR CEREBELLAR PEDUNCLE (left)';
    'CEREBRAL PEDUNCLE (left)';
    'ANTERIOR LIMB OF INTERNAL CAPSULE (left)';
    'POSTERIOR LIMB OF INTERNAL CAPSULE (left)';
    'POSTERIOR THALAMIC RADIATION (left)';
    'ANTERIOR CORONA RADIATA (left)';
    'SUPERIOR CORONA RADIATA (left)';
    'POSTERIOR CORONA RADIATA (left)';
    'CINGULUM (cingulate gyrus, left)';
    'CINGULUM (hippocampus, left)';
    'FORNIX (cres)/STRIA TERMINALIS (left)';
    'SUPERIOR LONGITUDINAL FASCICULUS (left)';
    'SUPERIOR FRONTO-OCCIPITAL FASCICULUS (left)';
    'INFERIOR FRONTO-OCCIPITAL FASCICULUS (left)';
    'SAGITTAL STRATUM (left)';
    'EXTERNAL CAPSULE (left)';
    'UNCINATE FASCICULUS (left)';
    'PONTINE CROSSING TRACT (left)';
    'MIDDLE CEREBELLAR PEDUNCLE (left)';
    'FORNIX (column and body, left)';
    'GENU OF CORPUS CALLOSUM (left)';
    'BODY OF CORPUS CALLOSUM (left)';
    'SPLENIUM OF CORPUS CALLOSUM (left)';
    'RETROLENTICULAR PART OF INTERNAL CAPSULE (left)';
    'RED NUCLEUS (left)';
    'SUBSTANTIA NIGRA (left)';
    'TAPETUM (left)';
    'CAUDATE NUCLEUS (left)';
    'PUTAMEN (left)';
    'THALAMUS (left)';
    'GLOBUS PALLIDUS (left)';
    'MIDBRAIN (left)';
    'PONS (left)';
    'MEDULLA (left)';
    'SUPERIOR PARIETAL LOBULE (right)';
    'CINGULATE GYRUS (right)';
    'SUPERIOR FRONTAL GYRUS (right)';
    'MIDDLE FRONTAL GYRUS (right)';
    'INFERIOR FRONTAL GYRUS (right)';
    'PRECENTRAL GYRUS (right)';
    'POSTCENTRAL GYRUS (right)';
    'ANGULAR GYRUS (right)';
    'PRECUNEUS (right)';
    'CUNEUS (right)';
    'LINGUAL GYRUS (right)';
    'FUSIFORM GYRUS (right)';
    'PARAHIPPOCAMPAL GYRUS (right)';
    'SUPERIOR OCCIPITAL GYRUS (right)';
    'INFERIOR OCCIPITAL GYRUS (right)';
    'MIDDLE OCCIPITAL GYRUS (right)';
    'ENTORHINAL AREA (right)';
    'SUPERIOR TEMPORAL GYRUS (right)';
    'INFERIOR TEMPORAL GYRUS (right)';
    'MIDDLE TEMPORAL GYRUS (right)';
    'LATERAL FRONTO-ORBITAL GYRUS (right)';
    'MIDDLE FRONTO-ORBITAL GYRUS (right)';
    'SUPRAMARGINAL GYRUS (right)';
    'GYRUS RECTUS (right)';
    'INSULA (right)';
    'AMYGDALA (right)';
    'HIPPOCAMPUS (right)';
    'CEREBELLUM (right)';
    'CORTICOSPINAL TRACT (right)';
    'INFERIOR CEREBELLAR PEDUNCLE (right)';
    'MEDIAL LEMNISCUS (right)';
    'SUPERIOR CEREBELLAR PEDUNCLE (right)';
    'CEREBRAL PEDUNCLE (right)';
    'ANTERIOR LIMB OF INTERNAL CAPSULE (right)';
    'POSTERIOR LIMB OF INTERNAL CAPSULE (right)';
    'POSTERIOR THALAMIC RADIATION (right)';
    'ANTERIOR CORONA RADIATA (right)';
    'SUPERIOR CORONA RADIATA (right)';
    'POSTERIOR CORONA RADIATA (right)';
    'CINGULUM (cingulate gyrus, right)';
    'CINGULUM (hippocampus, right)';
    'FORNIX (cres)/STRIA TERMINALIS (right)';
    'SUPERIOR LONGITUDINAL FASCICULUS (right)';
    'SUPERIOR FRONTO-OCCIPITAL FASCICULUS (right)';
    'INFERIOR FRONTO-OCCIPITAL FASCICULUS (right)';
    'SAGITTAL STRATUM (right)';
    'EXTERNAL CAPSULE (right)';
    'UNCINATE FASCICULUS (right)';
    'PONTINE CROSSING TRACT (right)';
    'MIDDLE CEREBELLAR PEDUNCLE (right)';
    'FORNIX (column and body, right)';
    'GENU OF CORPUS CALLOSUM (right)';
    'BODY OF CORPUS CALLOSUM (right)';
    'SPLENIUM OF CORPUS CALLOSUM (right)';
    'RETROLENTICULAR PART OF INTERNAL CAPSULE (right)';
    'RED NUCLEUS (right)';
    'SUBSTANTIA NIGRA (right)';
    'TAPETUM (right)';
    'CAUDATE NUCLEUS (right)';
    'PUTAMEN (right)';
    'THALAMUS (right)';
    'GLOBUS PALLIDUS (right)';
    'MIDBRAIN (right)';
    'PONS (right)';
    'MEDULLA (right)'

};

[path , name , ext] = fileparts(labelDir);
w_label = fullfile(path,['w' name ext]);
ROI = spm_read_vols(spm_vol(w_label)) > 0;

struc_no = [];
tmp = 1;
for j = 1 : length(atlas)
    infarct = (JHU == j) .* (ROI == 1);
    infarct(infarct ==0) = [];
    if isempty(infarct) ~= 1
        struc_no(tmp) = j;
        struc{tmp} = atlas{j};
        tmp = tmp + 1;
    end
end



%% 定量
segment_result = zeros(size(ROI));
[x, y, z] = size(ROI);
for i = 1:x
    for j = 1:y
        for k = 1:z
            if(JHU(i,j,k)*ROI(i,j,k) > 0)
                segment_result(i,j,k) = JHU(i,j,k);
            end
        end
    end
end

%%% region threshold
region = zeros(1,length(struc_no));
for i= 1:length(struc_no)
    stroke_on_atlas = sum(segment_result(:) == struc_no(i));
    stroke_total_size = sum(segment_result(:) > 0);
    region_ratio =  stroke_on_atlas / stroke_total_size;
    region(i) = region_ratio * 100;
end

%%% lesion threshold
lesion = zeros(1,length(struc_no));
for i = 1:length(struc_no)
    area = sum(JHU(:) == struc_no(i)); 
    stroke = sum(segment_result(:) == struc_no(i));
    lesion_ratio = stroke / area;          
    lesion(i) = lesion_ratio * 100;
end

%%% absolute
absolute = zeros(1,length(struc_no));
for i = 1:length(struc_no)
    sum_stroke_voxel = sum(segment_result(:) == struc_no(i));
    absolute(i) = sum_stroke_voxel / 1000;
end

%% 印結果
 
% for i = 1:length(struc_no)
%     if region(i) > 5 || lesion(i) > 10 || absolute(i) > 0.12
%         fprintf('%s  region: %.2f%%  lesion: %.2f%%  volume: %.2f mL\n', struc{i}, region(i), lesion(i), absolute(i));
%     else
%         continue
%     end
% end

for i = 1:length(struc_no)
    fprintf('%s  region: %.2f%%  lesion: %.2f%%  volume: %.2f mL\n', struc{i}, region(i), lesion(i), absolute(i));
end