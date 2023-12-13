toolpath='F:\matalab\toolbox\spm\toolbox\decoding';
addpath(genpath(toolpath));
spm('defaults', 'FMRI');
path=['..',filesep,'fMRI_data'];
subfolders=dir([path,'\sub*']);
for xx=1:length(subfolders)
    subfold=dir([path,'\' subfolders(xx).name '\MVPA_analysis_first_level*']);
    for mm=1:length(subfold)
        
        %% 1. setup paths
        subpath=[path,'\' subfolders(xx).name '\' subfold(mm).name];
        ROIfile=fullfile(subpath,'mask.nii');
        
        %% 2.extract SPM.mat
        load([subpath,'\SPM.mat']);
        for i=1:length(SPM.Vbeta)
            betafile{i,1}=SPM.Vbeta(i).fname;
            betafile{i,2}=SPM.Vbeta(i).descrip;
        end
        
        %% 3.1. run the  SF(OFvsOUF)
        SF_OF_run1_images=extract_beta(subpath,betafile,{'Sn(1)';'1SF_OF'});
        SF_OF_run2_images=extract_beta(subpath,betafile,{'Sn(2)';'1SF_OF'});
        SF_OUF_run1_images=extract_beta(subpath,betafile,{'Sn(1)';'2SF_OUF'});
        SF_OUF_run2_images=extract_beta(subpath,betafile,{'Sn(2)';'2SF_OUF'});
        outfolder=fullfile(subpath,'decoding_SF(OFvsOUF)_searchlight');
        MVPA_analysis(SF_OF_run1_images,SF_OF_run2_images,SF_OUF_run1_images,SF_OUF_run2_images,'1SF_OF','2SF_OUF',outfolder,ROIfile)
        
        %% 3.2. run the SUF(OFvsOUF) 
        SUF_OF_run1_images=extract_beta(subpath,betafile,{'Sn(1)';'3SUF_OF'});
        SUF_OF_run2_images=extract_beta(subpath,betafile,{'Sn(2)';'3SUF_OF'});
        SUF_OUF_run1_images=extract_beta(subpath,betafile,{'Sn(1)';'4SUF_OUF'});
        SUF_OUF_run2_images=extract_beta(subpath,betafile,{'Sn(2)';'4SUF_OUF'});
        outfolder=fullfile(subpath,'decoding_SUF(OFvsOUF)_searchlight');
        MVPA_analysis(SUF_OF_run1_images,SUF_OF_run2_images,SUF_OUF_run1_images,SUF_OUF_run2_images,'3SUF_OF','4SUF_OUF',outfolder,ROIfile)
        
        %% 3.3. run the OF(SFvsSUF) 
        SF_OF_run1_images=extract_beta(subpath,betafile,{'Sn(1)';'1SF_OF'});
        SF_OF_run2_images=extract_beta(subpath,betafile,{'Sn(2)';'1SF_OF'});
        SUF_OF_run1_images=extract_beta(subpath,betafile,{'Sn(1)';'3SUF_OF'});
        SUF_OF_run2_images=extract_beta(subpath,betafile,{'Sn(2)';'3SUF_OF'});
        outfolder=fullfile(subpath,'decoding_OF(SFvsSUF)_searchlight');
        MVPA_analysis(SF_OF_run1_images,SF_OF_run2_images,SUF_OF_run1_images,SUF_OF_run2_images,'1SF_OF','3SUF_OF',outfolder,ROIfile)
        
        %% 3.4. run the  OUF(SFvsSUF) 
        SF_OUF_run1_images=extract_beta(subpath,betafile,{'Sn(1)';'2SF_OUF'});
        SF_OUF_run2_images=extract_beta(subpath,betafile,{'Sn(2)';'2SF_OUF'});
        SUF_OUF_run1_images=extract_beta(subpath,betafile,{'Sn(1)';'4SUF_OUF'});
        SUF_OUF_run2_images=extract_beta(subpath,betafile,{'Sn(2)';'4SUF_OUF'});
        outfolder=fullfile(subpath,'decoding_OUF(SFvsSUF)_searchlight');
        MVPA_analysis(SF_OUF_run1_images,SF_OUF_run2_images,SUF_OUF_run1_images,SUF_OUF_run2_images,'2SF_OUF','4SUF_OUF',outfolder,ROIfile)
 
        %% 3.5. run the  SelfFairness         
        SelfFair_run1_images=[extract_beta(subpath,betafile,{'Sn(1)';'1SF_OF'});extract_beta(subpath,betafile,{'Sn(1)';'2SF_OUF'})];
        SelfFair_run2_images=[extract_beta(subpath,betafile,{'Sn(2)';'1SF_OF'});extract_beta(subpath,betafile,{'Sn(2)';'2SF_OUF'})];
        SelfUnfair_run1_images=[extract_beta(subpath,betafile,{'Sn(1)';'3SUF_OF'});extract_beta(subpath,betafile,{'Sn(1)';'4SUF_OUF'})];
        SelfUnfair_run2_images=[extract_beta(subpath,betafile,{'Sn(2)';'3SUF_OF'});extract_beta(subpath,betafile,{'Sn(2)';'4SUF_OUF'})];
        outfolder=fullfile(subpath,'decoding_MainE_SelfFairness_searchlight');
        MVPA_analysis(SelfFair_run1_images,SelfFair_run2_images,SelfUnfair_run1_images,SelfUnfair_run2_images,'SelfFair','SelfUnfair',outfolder,ROIfile)
        
        %% 3.6. run the OtherFairness
        OtherFair_run1_images=[extract_beta(subpath,betafile,{'Sn(1)';'1SF_OF'});extract_beta(subpath,betafile,{'Sn(1)';'3SUF_OF'})];
        OtherFair_run2_images=[extract_beta(subpath,betafile,{'Sn(2)';'1SF_OF'});extract_beta(subpath,betafile,{'Sn(2)';'3SUF_OF'})];
        OtherUnfair_run1_images=[extract_beta(subpath,betafile,{'Sn(1)';'2SF_OUF'});extract_beta(subpath,betafile,{'Sn(1)';'4SUF_OUF'})];
        OtherUnfair_run2_images=[extract_beta(subpath,betafile,{'Sn(2)';'2SF_OUF'});extract_beta(subpath,betafile,{'Sn(2)';'4SUF_OUF'})];
        outfolder=fullfile(subpath,'decoding_MainE_OtherFairness_searchlight');
        MVPA_analysis(OtherFair_run1_images,OtherFair_run2_images,OtherUnfair_run1_images,OtherUnfair_run2_images,'OtherFair','OtherUnfair',outfolder,ROIfile)
      
    end
    clear betafile
end