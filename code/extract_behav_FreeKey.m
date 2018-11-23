clear all;
close all;
clc
folder = 'C:\Users\Etudiant\Desktop\Manip JM\Code + stim tâche action\data\';

sublist = {'32' '33' '34' '35' '36'};

j=1;
nsub = length(sublist);

for isub = 1:nsub

    fprintf('\nsubject %s... ',sublist{isub});
    name_file = dir([folder 'ATTEMORPH_FreeKey_S' sublist{isub} '_*.mat']);
    
    load([folder name_file.name]);
    
    nblocs = size(response,1);
    nstims = size(response,2);
    
    for ibloc=1:nblocs
        
        fprintf('\n     extracting bloc %d... ',ibloc);
        
        for istim=1:nstims            
            cstimulus(ibloc).emotion(1,istim) = stimulus(ibloc,istim).emotion;
            cstimulus(ibloc).trial(1,istim) = stimulus(ibloc,istim).trial;
            cstimulus(ibloc).gender(1,istim) = stimulus(ibloc,istim).gender;
            cstimulus(ibloc).pair(1,istim) = stimulus(ibloc,istim).pair;
            cstimulus(ibloc).side(1,istim) = stimulus(ibloc,istim).side;
            cstimulus(ibloc).intensity(1,istim) = stimulus(ibloc,istim).intensity;
            cstimulus(ibloc).orient(1,istim) = stimulus(ibloc,istim).orient;
        end
        xlswrite('Data_ATTEMORPH_FreeKey', {'subject', 'bloc', 'trial', 'emotion', 'reverse', 'gender', 'pair', 'side', 'orient', 'intensity',...
            'response','first choice','time first choice', 'second choice', 'time second choice', 'time between answers', 'hesitations', 'choices','time release-press', 'iscor'},'Feuil1');
        xlswrite('Data_ATTEMORPH_FreeKey', ones(nstims,1)*(str2double(sublist{isub})),  'Feuil1', strcat('A',num2str(j+1)));
        xlswrite('Data_ATTEMORPH_FreeKey', ones(nstims,1)*(ibloc), 'Feuil1' , strcat('B',num2str(j+1)));
        xlswrite('Data_ATTEMORPH_FreeKey', (1:nstims)', 'Feuil1' , strcat('C',num2str(j+1)));
        xlswrite('Data_ATTEMORPH_FreeKey', cstimulus(ibloc).emotion', 'Feuil1' , strcat('D',num2str(j+1)));
        xlswrite('Data_ATTEMORPH_FreeKey', cstimulus(ibloc).trial','Feuil1' , strcat('E',num2str(j+1)));
        xlswrite('Data_ATTEMORPH_FreeKey', cstimulus(ibloc).gender','Feuil1' , strcat('F',num2str(j+1)));
        xlswrite('Data_ATTEMORPH_FreeKey', cstimulus(ibloc).pair','Feuil1' , strcat('G',num2str(j+1)));
        xlswrite('Data_ATTEMORPH_FreeKey', cstimulus(ibloc).side', 'Feuil1' , strcat('H',num2str(j+1)));
        xlswrite('Data_ATTEMORPH_FreeKey', cstimulus(ibloc).orient', 'Feuil1' , strcat('I',num2str(j+1)));
        xlswrite('Data_ATTEMORPH_FreeKey', cstimulus(ibloc).intensity', 'Feuil1' , strcat('J',num2str(j+1)));
        xlswrite('Data_ATTEMORPH_FreeKey', cresponse(ibloc).resp', 'Feuil1' , strcat('K',num2str(j+1)));
        xlswrite('Data_ATTEMORPH_FreeKey', cresponse(ibloc).firstChoice', 'Feuil1' , strcat('L',num2str(j+1)));
        xlswrite('Data_ATTEMORPH_FreeKey', cresponse(ibloc).timeFirstChoice', 'Feuil1' , strcat('M',num2str(j+1)));
        xlswrite('Data_ATTEMORPH_FreeKey', cresponse(ibloc).secondChoice', 'Feuil1' , strcat('N',num2str(j+1)));
        xlswrite('Data_ATTEMORPH_FreeKey', cresponse(ibloc).timeSecondChoice', 'Feuil1' , strcat('O',num2str(j+1)));
        xlswrite('Data_ATTEMORPH_FreeKey', cresponse(ibloc).timeBetweenAnswers', 'Feuil1' , strcat('P',num2str(j+1)));
        xlswrite('Data_ATTEMORPH_FreeKey', cresponse(ibloc).nbHesitations', 'Feuil1' , strcat('Q',num2str(j+1)));
        xlswrite('Data_ATTEMORPH_FreeKey', cresponse(ibloc).nbChoices', 'Feuil1' , strcat('R',num2str(j+1)));
        xlswrite('Data_ATTEMORPH_FreeKey', cresponse(ibloc).timeReleasePress', 'Feuil1' , strcat('S',num2str(j+1)));
        xlswrite('Data_ATTEMORPH_FreeKey', cresponse(ibloc).iscor', 'Feuil1' , strcat('T',num2str(j+1)));

        j= j+size(response,2);
        fprintf('done! ');        
    end
    fprintf('\n');
    
end
