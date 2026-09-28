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
data_path = {
    'C:\Users\andrew\Desktop\outdata_361\00099268\00099268_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\00109158\00109158_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\00119591\00119591_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\00168285\00168285_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\00188917\00188917_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\00359300\00359300_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\00388775\00388775_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\00419165\00419165_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\00419257\00419257_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\00439361\00439361_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\00448936\00448936_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\00449360\00449360_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\00699079\00699079_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\00738761\00738761_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\00809447\00809447_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\00819149\00819149_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\00819781\00819781_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\00859725\00859725_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\00888992\00888992_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\00899189\00899189_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\00959470\00959470_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\00959760\00959760_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\00999070\00999070_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\01058516\01058516_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\01128806\01128806_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\01139765\01139765_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\01188442\01188442_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\01299056\01299056_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\01299537\01299537_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\01318634\01318634_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\01318665\01318665_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\01328954\01328954_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\01459658\01459658_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\01468575\01468575_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\01479564\01479564_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\01509179\01509179_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\01579196\01579196_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\01648779\01648779_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\01648922\01648922_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\01679889\01679889_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\01699276\01699276_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\01748622\01748622_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\01748639\01748639_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\01849480\01849480_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\01849800\01849800_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\01949098\01949098_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\01949623\01949623_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\02069160\02069160_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\02079039\02079039_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\02088604\02088604_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\02179340\02179340_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\02278647\02278647_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\02379450\02379450_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\02519627\02519627_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\02529695\02529695_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\02569141\02569141_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\02608796\02608796_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\02639509\02639509_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\02708991\02708991_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\02709493\02709493_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\02749628\02749628_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\02798992\02798992_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\02929006\02929006_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\02958723\02958723_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\02958891\02958891_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\02988553\02988553_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\03309265\03309265_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\03318939\03318939_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\03339491\03339491_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\03359055\03359055_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\03369061\03369061_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\03609334\03609334_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\03609426\03609426_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\03609594\03609594_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\03629509\03629509_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\03708877\03708877_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\03728806\03728806_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\03779082\03779082_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\03898806\03898806_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\03969124\03969124_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\03979239\03979239_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\04068864\04068864_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\04069519\04069519_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\04079723\04079723_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\04079785\04079785_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\04088473\04088473_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\04119108\04119108_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\04119726\04119726_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\04178662\04178662_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\04189651\04189651_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\04198479\04198479_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\04248884\04248884_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\04279499\04279499_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\04289726\04289726_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\04379137\04379137_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\04399739\04399739_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\04439787\04439787_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\04539357\04539357_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\04579308\04579308_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\04698627\04698627_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\04749756\04749756_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\04788663\04788663_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\04819428\04819428_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\04959704\04959704_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\05019605\05019605_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\05029659\05029659_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\05079272\05079272_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\05118551\05118551_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\05159486\05159486_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\05209495\05209495_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\05289336\05289336_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\05488869\05488869_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\05579130\05579130_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\05589139\05589139_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\05589184\05589184_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\05679656\05679656_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\05708950\05708950_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\05779400\05779400_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\05789447\05789447_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\05818901\05818901_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\05848359\05848359_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\05878677\05878677_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\05999419\05999419_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\06009391\06009391_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\06049571\06049571_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\06138923\06138923_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\06159614\06159614_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\06339566\06339566_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\06369433\06369433_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\06378947\06378947_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\06379296\06379296_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\06498720\06498720_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\06518558\06518558_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\06588629\06588629_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\06659084\06659084_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\06748801\06748801_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\06759210\06759210_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\06828817\06828817_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\06849324\06849324_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\06889191\06889191_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\06939254\06939254_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\06988535\06988535_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\06999425\06999425_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\06999661\06999661_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\07059654\07059654_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\07089347\07089347_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\07109243\07109243_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\07218594\07218594_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\07319413\07319413_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\07348796\07348796_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\07458730\07458730_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\07488768\07488768_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\07568484\07568484_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\07579176\07579176_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\07619216\07619216_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\07719602\07719602_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\07879573\07879573_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\07899090\07899090_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\07919552\07919552_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\07929117\07929117_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\07949665\07949665_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\07979549\07979549_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\07999622\07999622_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\08009795\08009795_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\08029533\08029533_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\08098614\08098614_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\08229735\08229735_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\08348580\08348580_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\08389668\08389668_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\08429043\08429043_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\08439226\08439226_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\08469568\08469568_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\08509783\08509783_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\08759652\08759652_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\08848936\08848936_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\08888956\08888956_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\08998471\08998471_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\09009824\09009824_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\09019472\09019472_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\09119448\09119448_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\09139644\09139644_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\09168439\09168439_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\09208876\09208876_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\09589050\09589050_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\09608898\09608898_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\09808908\09808908_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\09909568\09909568_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\09969388\09969388_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\09989355\09989355_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\10038417\10038417_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\10058866\10058866_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\10169616\10169616_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\10239012\10239012_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\10278691\10278691_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\10298538\10298538_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\10329553\10329553_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\10338777\10338777_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\10419742\10419742_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\10458635\10458635_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\10539464\10539464_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\10589360\10589360_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\10598744\10598744_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\10608559\10608559_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\10639140\10639140_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\10769274\10769274_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\10809574\10809574_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\11009539\11009539_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\11018845\11018845_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\11109185\11109185_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\11209397\11209397_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\11228787\11228787_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\11249560\11249560_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\11379724\11379724_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\11458801\11458801_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\11608954\11608954_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\11748469\11748469_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\11759700\11759700_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\11769723\11769723_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\11789011\11789011_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\11798440\11798440_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\11808286\11808286_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\11829489\11829489_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\11879156\11879156_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\12009934\12009934_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\12049060\12049060_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\12069136\12069136_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\12139532\12139532_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\12288667\12288667_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\12298888\12298888_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\12438383\12438383_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\12509403\12509403_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\12518870\12518870_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\12559309\12559309_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\12589993\12589993_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\12788709\12788709_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\12839647\12839647_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\12939743\12939743_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\12969764\12969764_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\12978704\12978704_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\12979787\12979787_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\13008707\13008707_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\13008875\13008875_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\13038346\13038346_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\13159577\13159577_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\13178424\13178424_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\13188706\13188706_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\13209616\13209616_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\13278612\13278612_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\13359311\13359311_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\13368924\13368924_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\13378626\13378626_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\13438702\13438702_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\13469706\13469706_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\13589664\13589664_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\13599236\13599236_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\13698717\13698717_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\13699578\13699578_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\13719825\13719825_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\13828848\13828848_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\13959702\13959702_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\13989556\13989556_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\14098394\14098394_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\14109175\14109175_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\14128718\14128718_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\14268605\14268605_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\14299395\14299395_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\14418635\14418635_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\14489765\14489765_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\14509524\14509524_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\14559895\14559895_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\14859681\14859681_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\14929575\14929575_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\14999080\14999080_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\15169314\15169314_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\15199366\15199366_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\15239468\15239468_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\15269311\15269311_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\15278955\15278955_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\15358596\15358596_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\15378532\15378532_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\15418375\15418375_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\15468912\15468912_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\15519492\15519492_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\15529781\15529781_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\15779377\15779377_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\15789383\15789383_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\15819271\15819271_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\15908289\15908289_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\15958703\15958703_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\15999119\15999119_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\16008469\16008469_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\16149933\16149933_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\16188543\16188543_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\16189366\16189366_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\16259045\16259045_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\16278671\16278671_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\16388646\16388646_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\16548736\16548736_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\16769278\16769278_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\16809035\16809035_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\16998821\16998821_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\16999156\16999156_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\17028558\17028558_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\17089344\17089344_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\17138820\17138820_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\17149543\17149543_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\17378479\17378479_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\17468675\17468675_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\17499266\17499266_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\17579586\17579586_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\17628420\17628420_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\17768898\17768898_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\17879556\17879556_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\18058677\18058677_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\18178887\18178887_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\18249310\18249310_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\18308963\18308963_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\18388859\18388859_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\18469510\18469510_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\18489723\18489723_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\18498480\18498480_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\18729522\18729522_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\19228765\19228765_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\19269577\19269577_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\19429926\19429926_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\19488817\19488817_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\19529756\19529756_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\20219479\20219479_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\20658964\20658964_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\21008911\21008911_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\21019177\21019177_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\21069660\21069660_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\21098448\21098448_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\21099681\21099681_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\21549247\21549247_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\21728680\21728680_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\22348955\22348955_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\22699712\22699712_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\23398911\23398911_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\23399055\23399055_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\23729197\23729197_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\23889105\23889105_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\25488887\25488887_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\26199195\26199195_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\26299208\26299208_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\26378866\26378866_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\26639516\26639516_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\26989307\26989307_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\27549197\27549197_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\27599697\27599697_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\27709645\27709645_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\27838925\27838925_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\27969254\27969254_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\29229042\29229042_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\29758429\29758429_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\29788440\29788440_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\29829334\29829334_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\29888577\29888577_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\29909012\29909012_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\30339389\30339389_DWI.nii'
    'C:\Users\andrew\Desktop\outdata_361\30719501\30719501_DWI.nii'

    };

all_result = cell(length(data_path), 2);
row_idx = 1;

for i = 1:length(data_path)

    current_file = strtrim(data_path{i});

    if startsWith(current_file, '"') && endsWith(current_file, '"')
        current_file = current_file(2:end-1);
    end

    if isempty(current_file)
        continue;
    end

    [dataDir, name, ext] = fileparts(current_file);
    path = dataDir;

    %% 計算 reorient matrix，並存成 SPM 可用的 reorient.mat
    V = spm_vol(current_file);
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
        mb_seg{1}.spm.tools.oldseg.data = {current_file};
        spm('defaults','fmri');
        spm_jobman('initcfg');
        spm_jobman('run', mb_seg);
    end

    %% 自動分割
    imageDir = fullfile(dataDir,'image');
    resultDir = fullfile(dataDir,'result');

    if ~exist(imageDir,'dir')
        mkdir(imageDir);
    end

    if ~exist(resultDir,'dir')
        mkdir(resultDir);
    end

    nii_file = current_file;
    [~, name, ext] = fileparts(nii_file);
    tmpNii = fullfile(imageDir, sprintf('%s%s', name, ext));
    copyfile(nii_file, tmpNii);
    gzip(tmpNii);
    delete(tmpNii);

    nii_gz = tmpNii + ".gz";
    new_name = name + "_0000.nii.gz";
    new_path = fullfile(imageDir, new_name);
    movefile(nii_gz, new_path);

    assert(isfile(new_path), "nnU-Net 輸入檔未成功建立：%s", new_path);

    cmd = sprintf('cmd /c ""%s" -d 2 -c 3d_fullres -f 1 -tr nnUNetTrainer_300epoch -i "%s" -o "%s""', ...
        exe, imageDir, resultDir);

    [status, output] = system(cmd);
    disp(status);
    disp(output);

    model_result = [name '.nii.gz'];
    labelDir = fullfile(resultDir , model_result);
    gunzip(labelDir);

    nozip = [name '.nii'];
    labelDir = fullfile(resultDir , nozip);

    %% normalize
    [pth, ~, ~] = fileparts(current_file);
    sn = dir(fullfile(pth,'*seg_sn*.mat'));
    sn_mat = fullfile(pth, sn(1).name);

    mb_nor = normalize.matlabbatch;
    mb_nor{1}.spm.tools.oldnorm.write.subj.matname  = {sn_mat};
    mb_nor{1}.spm.tools.oldnorm.write.subj.resample = {
        char(labelDir)
        char(current_file)
        };

    spm('defaults','fmri');
    spm_jobman('initcfg');
    spm_jobman('run', mb_nor);

    %% 對齊圖譜
    [path , name , ext] = fileparts(labelDir);
    w_label = fullfile(path,['w' name ext]);
    
    [path , name , ext] = fileparts(current_file);
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

    [label_path, label_name, label_ext] = fileparts(labelDir);
    w_label = fullfile(label_path, ['w' label_name label_ext]);
    ROI = spm_read_vols(spm_vol(w_label)) > 0;

    struc_no = [];
    struc = {};
    tmp = 1;
    for j = 1:length(atlas)
        infarct = (JHU == j) .* (ROI == 1);
        infarct(infarct == 0) = [];
        if ~isempty(infarct)
            struc_no(tmp) = j;
            struc{tmp} = atlas{j};
            tmp = tmp + 1;
        end
    end

    %% 定量
    segment_result = zeros(size(ROI));
    [x, y, z] = size(ROI);
    for xi = 1:x
        for yj = 1:y
            for zk = 1:z
                if(JHU(xi,yj,zk)*ROI(xi,yj,zk) > 0)
                    segment_result(xi,yj,zk) = JHU(xi,yj,zk);
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
        if region_ratio >= 0.05
            region(i) = region_ratio * 100;
        else
            region(i) = 0; 
        end
    end
    
    %%% lesion threshold
    lesion = zeros(1,length(struc_no));
    for i = 1:length(struc_no)
        area = sum(JHU(:) == struc_no(i)); 
        stroke = sum(segment_result(:) == struc_no(i));
        lesion_ratio = stroke / area;   
        if lesion_ratio >= 0.10         
            lesion(i) = lesion_ratio * 100;
        else
            lesion(i) = 0;
        end
    end
    
    %%% absolute
    absolute = zeros(1,length(struc_no));
    for i = 1:length(struc_no)
        sum_stroke_voxel = sum(segment_result(:) == struc_no(i));
        if sum_stroke_voxel >= 120
            absolute(i) = sum_stroke_voxel / 1000;
        else
            absolute(i) = 0;
        end
    end

    %% 把同一筆整理成同一格
    % region_lines = {};
    % lesion_lines = {};
    % absolute_lines = {};
    % 
    % for s = 1:length(struc_no)
    %     if region(s) >= 5
    %         region_lines{end+1} = sprintf('%s : %.2f%%', struc{s}, region(s));
    %     end
    % 
    %     if lesion(s) >= 10
    %         lesion_lines{end+1} = sprintf('%s : %.2f%%', struc{s}, lesion(s));
    %     end
    % 
    %     if absolute(s) >= 0.12
    %         absolute_lines{end+1} = sprintf('%s : %.2f mL', struc{s}, absolute(s));
    %     end
    % end
    % 
    % if isempty(region_lines)
    %     region_text = '';
    % else
    %     region_text = strjoin(region_lines, newline);
    % end
    % 
    % if isempty(lesion_lines)
    %     lesion_text = '';
    % else
    %     lesion_text = strjoin(lesion_lines, newline);
    % end
    % 
    % if isempty(absolute_lines)
    %     absolute_text = '';
    % else
    %     absolute_text = strjoin(absolute_lines, newline);
    % end
    % 
    % all_result(row_idx, :) = {name, region_text, lesion_text, absolute_text};
    % row_idx = row_idx + 1;
    
    location_lines = {};
    for s = 1:length(struc_no)
        if region(s) >= 5 || lesion(s) >= 10 || absolute(s) >= 0.12
            location_lines{end+1} = struc{s};
        end
    end

    if isempty(location_lines)
        location_text = '';
    else
        location_text = strjoin(location_lines, newline);
    end

    all_result(row_idx, :) = {name, location_text};
    row_idx = row_idx + 1;
end

% result_table = cell2table(all_result, 'VariableNames', {'Name', 'Region', 'Lesion', 'Absolute'});
result_table = cell2table(all_result(1:row_idx-1, :), 'VariableNames', {'Name', 'Location'});
writetable(result_table, 'out.xlsx');
fprintf('完成');
