function [stimulustraining] = ATTEMORPH_FreeKey_BuildTraining()


addpath('./Toolbox/Rand');

sOrient = {'L_cent','R_cent'}; % pour acteurs présentés au centre
folder = 'training_center';

if ~exist(strcat('../stim_',folder),'dir')
    error('stim folder not found!');
end

sEmot = {'N'};
sSide = {'N'};

nbPair = 1;
nbActor = 2;
nbGender = 2;
nbOrientation = 2;

stimulustraining = nan(3,12,[]);

mactone = {'M05'};
macttwo = {'M20'};

factone = {'F08'};
facttwo = {'F19'};

actors = cell(nbActor,nbPair,nbGender,nbOrientation); %actors(nbactor, pair, gender, orientation)

actors(1,:,1,1) = mactone;
actors(2,:,1,1) = macttwo;
actors(1,:,2,1) = factone;
actors(2,:,2,1) = facttwo;

actors(1,:,1,2) = macttwo;
actors(2,:,1,2) = mactone;
actors(1,:,2,2) = facttwo;
actors(2,:,2,2) = factone;

stimAllTraining = zeros(7, 12);
stimAllTraining(1,:) = repmat(kron(1, ones(1,12)), 1);                              % emotions (1:Neutral)
stimAllTraining(2,:) = repmat(kron(1:2, ones(1,6)), 1);                             % gender (1:Male 2:Female)
stimAllTraining(3,:) = repmat(kron(1, ones(1,12)), 1);                              % pair (1 / gender)
stimAllTraining(4,:) = repmat(kron(1:2, ones(1,3)), [1,2]);                         % orientation (1: actor1-actor2 2:actor2-actor1)
stimAllTraining(5,:) = repmat(kron(1, ones(1,12)), 1);                              % side (1:left, 2:right 3:neutral)
stimAllTraining(6,:) = repmat(kron(1, ones(1,12)), 1);                              % intensity (1:neutral)
stimAllTraining(7,:) = repmat(kron(1:3, ones(1)), [1,4]);                           % trial (1:reverse 0:normal)

for i = 1:length(stimAllTraining)
    if (stimAllTraining(7, i) == 2 || stimAllTraining(7, i) == 3)
        stimAllTraining(7, i) = 0;
    end
end

stimAllTraining = randpermcol(stimAllTraining);

nbBlocs = 3;
nbStimsTotal = 36;
nbStims = nbStimsTotal/nbBlocs;

for istim = 1:nbStims

    stimulustraining(1,istim).emotion = sEmot{stimAllTraining(1, istim)};
    stimulustraining(1,istim).trial = stimAllTraining(7, istim);

    stimulustraining(1,istim).gender = stimAllTraining(2, istim);
    stimulustraining(1,istim).pair = stimAllTraining(3, istim);

    stimulustraining(1,istim).side = sSide{stimAllTraining(5, istim)};
    stimulustraining(1,istim).orient = stimAllTraining(4, istim);
    stimulustraining(1,istim).intensity = stimAllTraining(6, istim);

    stimulustraining(1,istim).actor1 = actors{1,stimulustraining(1,istim).pair,stimAllTraining(2, istim),stimulustraining(1,istim).orient};
    stimulustraining(1,istim).actor2 = actors{2,stimulustraining(1,istim).pair,stimAllTraining(2, istim),stimulustraining(1,istim).orient};

    stimulustraining(1,istim).file{1} = sprintf(strcat('../stim_',folder,'/%s_D_%c_%d_',sOrient{1},'.jpg'), ... %formate les noms de fichiers
        actors{1,stimulustraining(1,istim).pair,stimAllTraining(2, istim),stimulustraining(1,istim).orient}, ...
        sEmot{1}, ...
        0);

    stimulustraining(1,istim).file{2} = sprintf(strcat('../stim_',folder,'/%s_D_%c_%d_',sOrient{2},'.jpg'), ... %formate les noms de fichiers
        actors{2,stimulustraining(1,istim).pair,stimAllTraining(2, istim),stimulustraining(1,istim).orient}, ...
        sEmot{1}, ...
        0) ;
end

stimulustraining(2, :) = randbloc(stimulustraining(1, :));
stimulustraining(3, :) = randbloc(stimulustraining(2, :));
    
save('stimulus');
end

