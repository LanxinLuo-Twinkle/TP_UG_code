root_path=['..',filesep,'fMRI_data'];
folders=dir([root_path,filesep,'sub*']);

for sub_num=1:length(folders)
    path=[root_path, '\' folders(sub_num).name];
    
    for run=1:2
        eve_type={'1SF_OF','2SF_OUF','3SUF_OF','4SUF_OUF','response1','response2','response3','response4'};
        %% getting onsets
        %read TXT in every folders
        nTXT=dir(fullfile([path], 'TP_UG_fMRI*.txt'));
        rData=textread([path '\' nTXT.name],'%s');
        [m,n]=size(rData);
        nData=reshape(rData,20,m*n/20);
        nData=nData';
        nData=nData(2:end,3:end);
        [m,n]=size(nData);
        nData3=zeros(m,n);
        
        for j=1:m
            for k=1:n
                nData3(j,k)=str2num(nData{j,k});
            end
        end
        nData=nData3;
        %% getting onsets
        temp_len=0;
        %% parameters for each run
        for typ_num=1:8
            if typ_num==1
                onset=nData(find(nData(:,4)==run & nData(:,7)==1),13);
                dur=4;
                
            elseif typ_num==2
                onset=nData(find(nData(:,4)==run & nData(:,7)==2),13);
                dur=4;
                
            elseif typ_num==3
                onset=nData(find(nData(:,4)==run & nData(:,7)==3),13);
                dur=4;
                
            elseif typ_num==4
                onset=nData(find(nData(:,4)==run & nData(:,7)==4),13);
                dur=4;
                
            elseif typ_num==5
                onset=nData(find(nData(:,4)==run & nData(:,7)==1),14);
                dur=3;
                
            elseif typ_num==6
                onset=nData(find(nData(:,4)==run & nData(:,7)==2),14);
                dur=3;
                
            elseif typ_num==7
                onset=nData(find(nData(:,4)==run & nData(:,7)==3),14);
                dur=3;
                
            elseif typ_num==8
                onset=nData(find(nData(:,4)==run & nData(:,7)==4),14);
                dur=3;
                
            end
            
            if isempty(onset)
                onset=['NaN'];
                dur=['NaN'];
            end
            
            if typ_num<5
                for yyz=1:length(onset)
                    eve_name=[eve_type{typ_num} '_' num2str(yyz)];
                    trial_onset=onset(yyz);
                    names{temp_len+yyz}=eve_name;
                    onsets{temp_len+yyz}=trial_onset;
                    durations{temp_len+yyz}=dur;
                    pmod(temp_len+yyz).name{1}='none';
                    pmod(temp_len+yyz).param{1}=0;
                    pmod(temp_len+yyz).poly{1}=1;
                    %onset=[];
                    %dur=[];
                end
                temp_len=length(onset)+temp_len;
            elseif typ_num>4&&typ_num<9
                names{36+typ_num}=eve_type{typ_num};
                onsets{36+typ_num}=onset;
                durations{36+typ_num}=dur;
                pmod(36+typ_num).name{1}='none'
                pmod(36+typ_num).param{1}=0;
                pmod(36+typ_num).poly{1}=1;
                onset=[];
                dur=[];
            end
            
            
            %save conditions.mat conditions;
            run1_path=[path '\'  'ge_func_3p5x3p5x3p5_270_0004'];
            run2_path=[path '\'  'ge_func_3p5x3p5x3p5_270_0005'];
            
            oup_name=['conditions_run0' num2str(run) '_MVPA_event40and4'];
            
            if run==1
                save([run1_path '\' oup_name], 'names', 'onsets', 'durations','pmod');
            elseif run==2
                save([run2_path '\' oup_name], 'names', 'onsets', 'durations','pmod');
            end
            
        end
    end
end