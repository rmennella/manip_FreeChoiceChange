
function [stimulus,response,cresponse,tstimcheck, T0, simulate_respCheck] = ATTEMORPH_FreeKey_RunExperiment(sid,stimulus,isIRM, eyetracker, ibloc, isRobot)

% add toolbox functions
addpath('./Toolbox/IO');
addpath('./Toolbox/Draw');
addpath('../../StimTemplate/');

video = struct;
if isIRM
    video.id = 1;
else
    video.id = 0;
end

%% INITIALIZE EYETRACKER AND RUN CALIBRATION FOR IBLOC = 1
if eyetracker && ibloc == 1
    % Connect
    Eyelink.Initialize
    
    % Need parameters ?
    Eyelink.LoadParameters
    
    % Open equivalent of Track.exe but in PTB
    Eyelink.OpenCalibration(video.id)
    
end

%% General settings and variables initialisation

% N blocs and stimuli
[nblocs, nstims] = size(stimulus);

% mean luminance and contrast to standardize images
mean_lumi = 0.4284;
mean_contr = 0.2022;

% N of pixel for cutting the original images. They will be always display
% on the full left and right part of the screen

% this cuts out the external arms of the chairs
% this will be cut on the right of the img on the left and on the right of the other one.
% figures on the y axis will be cut in proportion at line ...
cut_img_x = 70;

% TARGET position expressed in proportion of the x and y axes
targetDistonXaxis = 0.0781; %150;
targetDistonYaxis = 0.5; %550;

% DOT initial position expressed in proportion of the x and y axes
dot_x = 0.5;
dot_y = 0.8796;

% Open parallel port for triggers
% if eyetracker && isIRM
%     OpenParPort;
% end
% ------------------------------------------------------------------------------------------------%
%                                 TASK SETTINGS
% ------------------------------------------------------------------------------------------------%

% set button inputs for response collection (different for IRM and comport)
KbName('UnifyKeyNames');
keyquit = KbName('ESCAPE');
if isIRM
    IRMvolumeTrig = KbName('t');
    lKeyhand = KbName('y');
    rKeyhand = KbName('b');
    keywait = rKeyhand;
    time_exclFirstMRIvolumes = 1; % N seconds to wait after T0
else
    keywait = KbName('space');
    lKeyhand = KbName('S');
    rKeyhand = KbName('L');
end

% SET JITTER's EXTREMES in seconds
if isIRM
    jitter = [2 4];
else
    jitter = [0.5 0.75];
end

% set scene fixed duration
timeStim = 1.500;

% set gray screen fixed duration
timeGrScreen = 0.500;

% set dot size and speed
dotSize = 25;
coeffm = 1;
coeffs = 35; % try to undrestand why 35

% ------------------------------------------------------------------------------------------------%
%                                 SET TRIGGERS FOR EYETRACKER
% ------------------------------------------------------------------------------------------------%
%%%%%%%% STIMULI'S TRIGGERS %%%%%%%%%
% factors are: trial (normal,reverse), emotion (A,F,N), side de presentation de l'emotion (Left, right)
% normal
normal_anger_left = 111;
normal_anger_right = 112;

normal_fear_left = 121;
normal_fear_right = 122;

normal_neutral = 130;

% reverse
reverse_anger_left = 211;
reverse_anger_right = 212;

reverse_fear_left = 221;
reverse_fear_right = 222;

reverse_neutral = 230;

%%%%%%%% RESPONSES'S TRIGGERS %%%%%%%%%
% factors are: number of response (1,2), and side (left, right)
first_left = 11;
first_right = 12;

second_left = 21;
second_right = 22;

%%%%%%%% T0 TRIGGER %%%%%%%%%
t0_trig = 30;

%% END OF SETTINGS, START SCRIPT

% Is this a pilot session with simulated responses?
if isRobot
    %Initialize the java engine
    import java.awt.*;
    import java.awt.event.*;
    
    %Create a Robot-object to do the key-pressing
    rob=Robot;
end

% initialize response variable
response = [];
cresponse = [];
T0 = NaN; % only useful for IRM

try
    HideCursor;
    FlushEvents;
    ListenChar(2);
    Screen('Preference','VisualDebuglevel',1); % it was 3
    Screen('Preference','SkipSyncTests',0);
    PsychImaging('PrepareConfiguration');
    PsychImaging('AddTask','General','UseFastOffscreenWindows');
    PsychImaging('AddTask','General','NormalizedHighresColorRange');
    video.h = PsychImaging('OpenWindow',video.id,0);
    [video.x,video.y] = Screen('WindowSize',video.h);
    video.ifi = Screen('GetFlipInterval',video.h,100,50e-6,10);
    Screen('BlendFunction',video.h,GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
    LoadIdentityClut(video.h);
    Screen('ColorRange',video.h,1);
    Screen('TextFont',video.h,'Arial');
    Screen('TextSize',video.h,28);
    Screen('TextStyle',video.h,0);
    Priority(MaxPriority(video.h));
    
    Screen('FillRect',video.h,0);
    t = Screen('Flip',video.h);
    
    roundfr = @(dt)(round(dt/video.ifi)-0.5)*video.ifi;
    aborted = false;
    
    % old block loop started here
    tstimcheck.greyscreen = nan(1,nstims); %%%quand écran gris apparait
    tstimcheck.scene = nan(1,nstims);%%%%quand scene+cross apparait
    tstimcheck.repscreen = nan(1,nstims); %%%%quand écran de réponse apparait
    tstimcheck.timescene = nan(1,nstims); %temps stim visible
    tstimcheck.progrJitter = nan(1,nstims);
    tstimcheck.realJitter = nan(1,nstims);
    
    cresponse.firstChoice = zeros(1,nstims); % 1:left 2:right 0: no rep
    cresponse.timeFirstChoice = zeros(1,nstims); % 0: no rep
    cresponse.secondChoice = zeros(1,nstims); % 1:left 2:right 0: no final rep
    cresponse.timeSecondChoice = zeros(1,nstims); % 0:no final rep
    cresponse.timeBetweenAnswers = zeros(1,nstims); %time between first choice press and second choice press
    cresponse.timeGreyCross = zeros(1,nstims); %time fixation screen
    cresponse.dot = zeros(3, 2, nstims); %last coord of the dot when you push Q, when you push M and when you don't push any key
    cresponse.nbHesitations = zeros(1, nstims); %nb d'hesitations pour une seule direction
    cresponse.nbChoices = zeros(1, nstims); %nb de choix (max = 2)
    cresponse.timeRelease = zeros(1,nstims); %time button for first choice is release
    cresponse.timeReleasePress = zeros(1,nstims); %time between first choice release and second choice press
    cresponse.iscor = nan(1, nstims); % correct answer if resp is 1 or 2
    cresponse.resp = nan(1, nstims); %final answer
    
    
    %% INSTRUCTIONS
    % ------------------------------------------------------------------------------------------------%
    %                                 PAGE 1
    % ------------------------------------------------------------------------------------------------%
    labeltxt = strcat('Instructions :');
    labelrec = CenterRectOnPoint(Screen('TextBounds',video.h,labeltxt),video.x/2,video.y/2 - (0.4*video.y));
    Screen('DrawText',video.h,labeltxt,labelrec(1),labelrec(2),1);
    
    labeltxt = strcat('Une scène va apparaître, vous êtes dans une salle d''attente.');
    labelrec = CenterRectOnPoint(Screen('TextBounds',video.h,labeltxt),video.x/2,video.y/2- (0.30*video.y));
    Screen('DrawText',video.h,labeltxt,labelrec(1),labelrec(2),1);
    
    labeltxt = strcat('Vous devez choisir à quelle place vous souhaitez vous asseoir.');
    labelrec = CenterRectOnPoint(Screen('TextBounds',video.h,labeltxt),video.x/2,video.y/2- (0.25*video.y));
    Screen('DrawText',video.h,labeltxt,labelrec(1),labelrec(2),1);
    
    
    if isIRM
        labeltxt = strcat('Si vous souhaitez choisir le siège de gauche, appuyez sur la touche GAUCHE.');
        labelrec = CenterRectOnPoint(Screen('TextBounds',video.h,labeltxt),video.x/2,video.y/2- (0.15*video.y));
        Screen('DrawText',video.h,labeltxt,labelrec(1),labelrec(2),1);
        
        labeltxt = strcat('Si vous souhaitez choisir le siège de droite, appuyez sur la touche DROITE.');
        labelrec = CenterRectOnPoint(Screen('TextBounds',video.h,labeltxt),video.x/2,video.y/2- (0.10*video.y));
        Screen('DrawText',video.h,labeltxt,labelrec(1),labelrec(2),1);
    else
        labeltxt = strcat('Si vous souhaitez choisir le siège de gauche, appuyez sur S.');
        labelrec = CenterRectOnPoint(Screen('TextBounds',video.h,labeltxt),video.x/2,video.y/2- (0.15*video.y));
        Screen('DrawText',video.h,labeltxt,labelrec(1),labelrec(2),1);
        
        labeltxt = strcat('Si vous souhaitez choisir le siège de droite, appuyez sur L.');
        labelrec = CenterRectOnPoint(Screen('TextBounds',video.h,labeltxt),video.x/2,video.y/2- (0.10*video.y));
        Screen('DrawText',video.h,labeltxt,labelrec(1),labelrec(2),1);
    end
    
    labeltxt = strcat('Restez bien appuyé sur la touche JUSQU''A ce que votre photo apparaisse.');
    labelrec = CenterRectOnPoint(Screen('TextBounds',video.h,labeltxt),video.x/2,video.y/2);
    Screen('DrawText',video.h,labeltxt,labelrec(1),labelrec(2),1);
    
    labeltxt = strcat('A tout moment vous pouvez changer la direction du curseur en changeant de touche.');
    labelrec = CenterRectOnPoint(Screen('TextBounds',video.h,labeltxt),video.x/2,video.y/2+ (0.10*video.y));
    Screen('DrawText',video.h,labeltxt,labelrec(1),labelrec(2),1);
    
    if isIRM
        labeltxt = strcat('Dans certains essais, les touches sont inversées.');
        labelrec = CenterRectOnPoint(Screen('TextBounds',video.h,labeltxt),video.x/2,video.y/2+ (0.20*video.y));
        Screen('DrawText',video.h,labeltxt,labelrec(1),labelrec(2),1);
        
        labeltxt = strcat('La touche gauche amène votre curseur à droite et la touche droite à gauche. Restez attentifs !');
        labelrec = CenterRectOnPoint(Screen('TextBounds',video.h,labeltxt),video.x/2,video.y/2+ (0.25*video.y));
        Screen('DrawText',video.h,labeltxt,labelrec(1),labelrec(2),1);
        
        labeltxt = strcat('Merci d''appuyer sur la touche droite pour afficher la suite des instructions');
        labelrec = CenterRectOnPoint(Screen('TextBounds',video.h,labeltxt),video.x/2,video.y/2+ (0.4*video.y));
        Screen('DrawText',video.h,labeltxt,labelrec(1),labelrec(2),1);
        
    else
        labeltxt = strcat('Dans certains essais, les touches sont inversées.');
        labelrec = CenterRectOnPoint(Screen('TextBounds',video.h,labeltxt),video.x/2,video.y/2+ (0.20*video.y));
        Screen('DrawText',video.h,labeltxt,labelrec(1),labelrec(2),1);
        
        labeltxt = strcat('S amène votre curseur à droite et L à gauche. Restez attentifs !');
        labelrec = CenterRectOnPoint(Screen('TextBounds',video.h,labeltxt),video.x/2,video.y/2+ (0.25*video.y));
        Screen('DrawText',video.h,labeltxt,labelrec(1),labelrec(2),1);
        
        labeltxt = strcat('Merci d''appuyer sur espace pour afficher la suite des instructions');
        labelrec = CenterRectOnPoint(Screen('TextBounds',video.h,labeltxt),video.x/2,video.y/2+ (0.4*video.y));
        Screen('DrawText',video.h,labeltxt,labelrec(1),labelrec(2),1);
    end
    
    
    Screen('DrawingFinished',video.h);
    Screen('Flip',video.h,t+roundfr(1.000+0.250*rand));
    
    % wait for the subject to press a button to go to the 2nd page
    WaitKeyPress(keywait);
    
    % ------------------------------------------------------------------------------------------------%
    %                                 PAGE 2
    % ------------------------------------------------------------------------------------------------%
    
    labeltxt = strcat('Avant chaque scène, un écran gris avec une croix de fixation va apparaître.');
    labelrec = CenterRectOnPoint(Screen('TextBounds',video.h,labeltxt),video.x/2,video.y/2- (0.10*video.y));
    Screen('DrawText',video.h,labeltxt,labelrec(1),labelrec(2),1);
    
    labeltxt = strcat('Vous devrez fixer la croix TOUT AU LONG de l''essai.');
    labelrec = CenterRectOnPoint(Screen('TextBounds',video.h,labeltxt),video.x/2,video.y/2- (0.05*video.y));
    Screen('DrawText',video.h,labeltxt,labelrec(1),labelrec(2),1);
    
    labeltxt = strcat('Vous n''avez le droit de changer de direction qu''UNE SEULE FOIS pour chaque scène.');
    labelrec = CenterRectOnPoint(Screen('TextBounds',video.h,labeltxt),video.x/2,video.y/2+ (0.05*video.y));
    Screen('DrawText',video.h,labeltxt,labelrec(1),labelrec(2),1);
    
    if isIRM
        labeltxt = strcat('Merci d''appuyer sur la touche droite pour lancer le bloc n°',num2str(ibloc),'/6.');
        labelrec = CenterRectOnPoint(Screen('TextBounds',video.h,labeltxt),video.x/2,video.y/2+ (0.4*video.y));
        Screen('DrawText',video.h,labeltxt,labelrec(1),labelrec(2),1);
    else
        labeltxt = strcat('Merci d''appuyer sur espace pour lancer le bloc n°',num2str(ibloc),'/6.');
        labelrec = CenterRectOnPoint(Screen('TextBounds',video.h,labeltxt),video.x/2,video.y/2+ (0.4*video.y));
        Screen('DrawText',video.h,labeltxt,labelrec(1),labelrec(2),1);
    end
    
    Screen('DrawingFinished',video.h);
    Screen('Flip',video.h,t+roundfr(1.000+0.250*rand));
    
    % wait for the subject to press a button to end instructions
    WaitKeyPress(keywait);
    
    % start recording Eyelink file
    if eyetracker
        Eyelink.StartRecording(sprintf('S%02d_bl%d',sid,ibloc)), % open file, start recording
    end

    % In the IRM, wait for the trigger of the 1st volume and wait N seconds before starting.
    if isIRM
        
        % fixation cross
        [cross, ~, alpha] = imread('CROSS3.png');
        cross(:,:,4) = alpha(:,:);
        
        % grey screen
        img_greyscreen = double(imread('Greyscreen.jpg'))/255;
        img_greyscreen = img_greyscreen(:,:,1);
        
        % signal to the subject that the task is about to start
        labeltxt = 'La tâche va commencer bientôt';
        labelrec = CenterRectOnPoint(Screen('TextBounds',video.h,labeltxt),video.x/2,video.y/2- (0.10*video.y));
        Screen('DrawText',video.h,labeltxt,labelrec(1),labelrec(2),1);
        Screen('DrawingFinished',video.h);
        
        % flip and wait for the first MRI volume
        Screen('Flip',video.h);
        [~, T0, ~] = WaitKeyPress(IRMvolumeTrig); % wait for MRI trigger

        % SEND T0 TRIGGER
        %             WriteParPort(t0_trig)
        %             WaitSecs(0.003) % in seconds; use minium samplingRate x2, usually x3
        %             WriteParPort(0)
        Eyelink('Message', ['Trigger ' num2str(t0_trig)])
        WaitSecs(0.003)
        
         
        % signal to the subject that he needs to prepare!
        labeltxt = 'Préparez-vous !';
        labelrec = CenterRectOnPoint(Screen('TextBounds',video.h,labeltxt),video.x/2,video.y/2- (0.10*video.y));
        Screen('DrawText',video.h,labeltxt,labelrec(1),labelrec(2),1);
        Screen('DrawingFinished',video.h);
        
        % flip for 0.5s
        Screen('Flip',video.h);
        WaitSecs(0.5)
        
        % display fixation for some seconds in order to let the BOLD
        % stabilize
        
        timeCounter = GetSecs;
        while timeCounter - T0 <= time_exclFirstMRIvolumes
            timeCounter = GetSecs;
            if CheckKeyPress(keyquit)
                aborted = true;
                break
            end
            
        %grey screen
        patchtex = Screen('MakeTexture',video.h,img_greyscreen,[],[],1);
        patchrct = CenterRectOnPoint(Screen('Rect',patchtex),video.x/2,video.y/2);
        Screen('DrawTexture',video.h,patchtex,[],patchrct);
        
        %cross
        patchtex = Screen('MakeTexture',video.h,cross,[],[],[]);
        patchrct = CenterRectOnPoint(Screen('Rect',patchtex),video.x/2,video.y/2-(video.y*0.3611));
        Screen('DrawTexture',video.h,patchtex,[],patchrct);
        
        % Flip
        Screen('Flip',video.h)

        end
        
    else
        
        % just signal to the subject that he needs to prepare!
        labeltxt = 'Préparez-vous !';
        labelrec = CenterRectOnPoint(Screen('TextBounds',video.h,labeltxt),video.x/2,video.y/2- (0.10*video.y));
        Screen('DrawText',video.h,labeltxt,labelrec(1),labelrec(2),1);
        Screen('DrawingFinished',video.h);
        
        % flip for 0.5s
        Screen('Flip',video.h);
        WaitSecs(0.5)
    end
    %% START STIMULI LOOP
    % this is useful when we simulate responses
    simulate_respCheck.firstRT = nan(1,nstims);
    simulate_respCheck.secondRT = nan(1,nstims);
    simulate_respCheck.stimTrigger = nan(1,nstims);
    simulate_respCheck.first_respTrigger = nan(1,nstims);
    simulate_respCheck.second_respTrigger = nan(1,nstims);
    
    for istim = 1:nstims
        
        % empty stim and resp triggers
        stimTrigger = [];
        respTrigger = [];
        
        
        % Is this a pilot session with simulated responses?
        if isRobot
            
            % flip the coin to choose left or roght response
            coin = rand(1);
            if coin >= 0.5
                robotResp = 2;
                % set an even lower probability for response change
                if coin > 0.85
                    chResp = 1;
                else
                    chResp = 0;
                end
            else
                robotResp = 1;
                if coin < 0.15
                    chResp = 1;
                else
                    chResp = 0;
                end
            end
            
        end
        
        % initialise the response variable
        response(istim).firstChoice = 0; % 1:left 2:right 0: no rep
        response(istim).timeFirstChoice = 0; % 0: no rep
        response(istim).secondChoice = 0; % 1:left 2:right 0: no final rep
        response(istim).timeSecondChoice = 0; % 0:no final rep
        response(istim).timeBetweenAnswers = 0; %time between first choice press and second choice press
        response(istim).timeGreyCross = 0; %time fixation screen
        response(istim).dot = zeros(3, 2); %last coord of the dot when you push Q, when you push M and when you don't push any key
        response(istim).nbHesitations = 0; %nb d'hesitations pour une seule direction
        response(istim).nbChoices = 0; %nb de choix (max = 2)
        response(istim).timeRelease = 0; %time button for first choice is release
        response(istim).timeReleasePress = 0; %time between first choice release and second choice press
        response(istim).iscor = nan(1, nstims); % correct answer if resp is 1 or 2
        response(istim).resp = nan(1, nstims); %final answer
        
        %dot coord for free choice
        dot = [(dot_x*video.x) (dot_y*video.y)];
        
        % set the autorisations to true
        leftAutorization = true;
        rightAutorization = true;
        
        % where does the dot have to attain?
        target = [];
        target.left = [targetDistonXaxis*video.x targetDistonYaxis*video.y];
        target.right = [video.x-targetDistonXaxis*video.x  targetDistonYaxis*video.y];
        
        %save if the previous choice : left(1), right(2), nothing(0)
        previousChoice = 0;
        %save if you're hesiting (=true) or doing a choice (=false)
        hesitation = false;
        
        %boolean to know if this item is reverse for the key directions
        reverse = stimulus(ibloc,istim).trial;
        
        % CALCULATE THE JITTER FOR THE FIXATION
        timeCrossGrey = jitter(1) + (randi((jitter(2)*1000) - (jitter(1)*1000)))/1000;
        
        % save
        response(istim).timeGreyCross = timeCrossGrey;
        
        tpreptotal = 0;
        
        % Check for escape button to terminate trial eventually
        if CheckKeyPress(keyquit)
            aborted = true;
            break;
        end
        
        % ------------------------------------------------------------------------------------------------%
        %                                 LOAD IMAGES OF THE SCENE
        % ------------------------------------------------------------------------------------------------%
        
        % fixation cross
        [cross, ~, alpha] = imread('CROSS3.png');
        cross(:,:,4) = alpha(:,:);
        
        % grey screen
        img_greyscreen = double(imread('Greyscreen.jpg'))/255;
        img_greyscreen = img_greyscreen(:,:,1);
        
        % Picture on the left
        img = double(imread(stimulus(ibloc,istim).file{1}))/255;
        img = img(:,:,1);
        
        % Picture on the right
        img2 = double(imread(stimulus(ibloc,istim).file{2}))/255;
        img2 = img2(:,:,1);
        
        %normalise average luminance and contrast of the scene
        x = img(:);
        x2 = img2(:);
        lumi_img = mean([x;x2]);
        cont_img = std([x;x2]);
        img = (img-lumi_img)/cont_img;
        img2 = (img2-lumi_img)/cont_img;
        
        img = mean_lumi+img*mean_contr;
        img2 = mean_lumi+img2*mean_contr;
        
        % cut images for enlarging the distance between the two faces
        % Needed for the manip IRM because the screen is far (120cm). We
        % will project for a 1920 x 1080 resolution. On a screen like the
        % one in the lab, the distance between faces is 7.8 for male and
        % 8.3 for female cuples, with a mean angle of around 7.45 (it was 8
        % for Emma's task originally). Can't o better
        
        % cut images on the x axis to take out the external arms of the
        % chair
        img = img(:,cut_img_x:end);
        img2 = img2(:,1:(end-cut_img_x+1));
        
        % calculate how much I have to cut the y axis if I project the x
        % part of the scene on the x axis
        
        prop_change = (video.x/2)/size(img,2);
        newY = size(img,1)* prop_change;
        cut_img_y = round(newY - video.y,0);
        
        img = img(1:end-cut_img_y,:);
        img2 = img2(1:end-cut_img_y,:);
        
        % Participant's ID
        part = double(imread(['S' num2str(sid) '.jpg']))/255;
        part = part(:,:,1);
        
        %% select the good trigger to send to parallel port
        
        %%%% NORMAL TRIALS
        if stimulus(ibloc,istim).trial == 0
            % ANGER LEFT
            if (strcmp(stimulus(ibloc,istim).emotion, 'A')) && (strcmp(stimulus(ibloc,istim).side, 'L'))
                stimTrigger = normal_anger_left;
                
                % ANGER RIGHT
            elseif (strcmp(stimulus(ibloc,istim).emotion, 'A')) && (strcmp(stimulus(ibloc,istim).side, 'R'))
                stimTrigger = normal_anger_right;
                
                % FEAR LEFT
            elseif (strcmp(stimulus(ibloc,istim).emotion, 'F')) && (strcmp(stimulus(ibloc,istim).side, 'L'))
                stimTrigger = normal_fear_left;
                
                % FEAR RIGHT
            elseif (strcmp(stimulus(ibloc,istim).emotion, 'F')) && (strcmp(stimulus(ibloc,istim).side, 'R'))
                stimTrigger = normal_fear_right;
                
                % NEUTRAL
            elseif (strcmp(stimulus(ibloc,istim).emotion, 'N'))
                stimTrigger = normal_neutral;
                
            end
            
            %%%% REVERSE TRIALS
        elseif stimulus(ibloc,istim).trial == 1
            
            % ANGER LEFT
            if (strcmp(stimulus(ibloc,istim).emotion, 'A')) && (strcmp(stimulus(ibloc,istim).side, 'L'))
                stimTrigger = reverse_anger_left;
                
                % ANGER RIGHT
            elseif (strcmp(stimulus(ibloc,istim).emotion, 'A')) && (strcmp(stimulus(ibloc,istim).side, 'R'))
                stimTrigger = reverse_anger_right;
                
                % FEAR LEFT
            elseif (strcmp(stimulus(ibloc,istim).emotion, 'F')) && (strcmp(stimulus(ibloc,istim).side, 'L'))
                stimTrigger = reverse_fear_left;
                
                % FEAR RIGHT
            elseif (strcmp(stimulus(ibloc,istim).emotion, 'F')) && (strcmp(stimulus(ibloc,istim).side, 'R'))
                stimTrigger = reverse_fear_right;
                
                % NEUTRAL
            elseif (strcmp(stimulus(ibloc,istim).emotion, 'N'))
                stimTrigger = reverse_neutral;
                
            end
            
        end
        
        %% LET'S START TO PRESENT THINGS ON SCREEN
        
        % ------------------------------------------------------------------------------------------------%
        %                                 LOAD AND FLIP GRAYSCREEN
        % ------------------------------------------------------------------------------------------------%
        
        % grey screen without cross first
        patchtex = Screen('MakeTexture',video.h,img_greyscreen,[],[],1);
        patchrct = CenterRectOnPoint(Screen('Rect',patchtex),video.x/2,video.y/2);
        Screen('DrawTexture',video.h,patchtex,[],patchrct);
        
        tstart_greyscreen = Screen('Flip',video.h);
        
        % ------------------------------------------------------------------------------------------------%
        %                                 LOAD GREY SCREEN + FIXATION
        % ------------------------------------------------------------------------------------------------%
        
        %grey screen
        patchtex = Screen('MakeTexture',video.h,img_greyscreen,[],[],1);
        patchrct = CenterRectOnPoint(Screen('Rect',patchtex),video.x/2,video.y/2);
        Screen('DrawTexture',video.h,patchtex,[],patchrct);
        
        %cross
        patchtex = Screen('MakeTexture',video.h,cross,[],[],[]);
        patchrct = CenterRectOnPoint(Screen('Rect',patchtex),video.x/2,video.y/2-(video.y*0.3611));
        Screen('DrawTexture',video.h,patchtex,[],patchrct);
        
        % ------------------------------------------------------------------------------------------------%
        %                                 FLIP GREY SCREEN + FIXATION
        % ------------------------------------------------------------------------------------------------%
        
        % calculate precise timing for grey screen
        tcheckGrey = GetSecs;
        while tcheckGrey - tstart_greyscreen < timeGrScreen-video.ifi
            tcheckGrey = GetSecs;
        end
        
        if isIRM % for IRM you must check only response buttons, otherwise it will detect the MRI trigger
            keyRelease = 1;
            while keyRelease > 0
                keyRelease = CheckKeyPress([lKeyhand,rKeyhand]);
            end
        else
            keyRelease = 1;
            while keyRelease > 0
                keyRelease = KbCheck();
            end
        end
        
        tstartCross = Screen('Flip',video.h); %affichage grey+cross
        
        tstimcheck.greyscreen(istim) = tstartCross - tstart_greyscreen;
        
        % ------------------------------------------------------------------------------------------------%
        %             LOAD IMAGES IN THE BACKGROUND (during fixation jitter) AND FLIP SCENE
        %
        % ------------------------------------------------------------------------------------------------%
        % keep in mind that this is only the 1st flip of the scene, which we need for precise time
        % info about the presence of the scene on the screen. Since the dot
        % moves, there'll be many other flips
        
        % position of the images
        patchrct = [0 0 video.x/2 video.y];
        patchrct2 = [video.x/2 0 video.x video.y];
        
        %1st actor male
        patchtex = Screen('MakeTexture',video.h,img,[],[],1);
        Screen('DrawTexture',video.h,patchtex,[],patchrct);
        
        %2nd actor male
        patchtex = Screen('MakeTexture',video.h,img2,[],[],1);
        Screen('DrawTexture',video.h,patchtex,[],patchrct2);
        
        %cross
        patchtex = Screen('MakeTexture',video.h,cross,[],[],[]);
        patchrct = CenterRectOnPoint(Screen('Rect',patchtex),video.x/2,video.y/2-(video.y*0.3611));
        Screen('DrawTexture',video.h,patchtex,[],patchrct);
        
        % draw a dot in its first position in the middle of the screen
        Screen('DrawDots', video.h, dot, dotSize, [255 0 0 1]);
        
        % calculate precise timing for fixation
        tcheckFix = GetSecs;
        while tcheckFix - tstartCross < timeCrossGrey - video.ifi
            tcheckFix = GetSecs;
        end
        
        tstartScene = Screen('Flip',video.h);
        
        if eyetracker
            % SEND STIMULUS' TRIGGER
%             WriteParPort(stimTrigger)
%             WaitSecs(0.003) % in seconds; use minium samplingRate x2, usually x3
%             WriteParPort(0)
        Eyelink('Message', ['Trigger ' num2str(stimTrigger)])
        WaitSecs(0.003)
        
        else
            simulate_respCheck.stimTrigger(1,istim) = stimTrigger;
        end
        
        % save programmed and real fixation duration
        tstimcheck.progrJitter(istim) = timeCrossGrey;
        tstimcheck.realJitter(istim) = tstartScene - tstartCross;
        
        % ------------------------------------------------------------------------------------------------%
        %                         CREATE DOT ANIMATION AND COLLECT RESPONSE
        % ------------------------------------------------------------------------------------------------%
        
        tstim = GetSecs;
        while ( (tstim - tstartScene) < (timeStim - (video.ifi*3)) && dot(2) > target.left(2) )
            
            % check the length of a loop for calibration
            %GetSecs-tstim
            %update time calculation
            tstim = GetSecs;
            
            
            % check response
            [answerButton, answerTime_abs] = CheckKeyPress([lKeyhand,rKeyhand]);
            
            %%%%%%%%%%%%%%%%%%%%%% SEND OR SAVE RESP TRIGGER %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            %%%% IN CASE THE Subject RESPONDED LEFT
            if answerButton == 1
                
                %%% IF THIS IS THE FIRST RESPONSE (respTrigger is still empty)
                if isempty(respTrigger)
                    respTrigger = first_left;
                    
                    if eyetracker
                        % SEND RESPONSE's TRIGGER
                        %                         WriteParPort(respTrigger)
                        %                         WaitSecs(0.003) % in seconds; use minium samplingRate x2, usually x3
                        %                         WriteParPort(0)
                        
                        Eyelink('Message', ['Trigger ' num2str(respTrigger)])
                        WaitSecs(0.003)
                    else
                        simulate_respCheck.first_respTrigger(1,istim) = respTrigger;
                    end
                    
                    %%% THIS IS THE SECOND RESPONSE (respTrigger is not empty and it is different from the present response)
                elseif respTrigger == first_right
                    respTrigger = second_left;
                    
                    if eyetracker
                        % SEND RESPONSE's TRIGGER
%                         WriteParPort(respTrigger)
%                         WaitSecs(0.003) % in seconds; use minium samplingRate x2, usually x3
%                         WriteParPort(0)
                        Eyelink('Message', ['Trigger ' num2str(respTrigger)])
                        WaitSecs(0.003)
                    else
                        simulate_respCheck.second_respTrigger(1,istim) = respTrigger;
                    end
                    
                end
                
                %%%% IN CASE THE Subject RESPONDED RIGHT
            elseif answerButton == 2
                
                %%% IF THIS IS THE FIRST RESPONSE (respTrigger is empty)
                if isempty(respTrigger)
                    respTrigger = first_right;
                    
                    if eyetracker
                        % SEND RESPONSE's TRIGGER
%                         WriteParPort(respTrigger)
%                         WaitSecs(0.003) % in seconds; use minium samplingRate x2, usually x3
%                         WriteParPort(0)
                        Eyelink('Message', ['Trigger ' num2str(respTrigger)])
                        WaitSecs(0.003)
                    else
                        simulate_respCheck.first_respTrigger(1,istim) = respTrigger;
                    end
                    
                    %%% THIS IS THE SECOND RESPONSE (respTrigger is not empty and it is different from the present response)
                elseif respTrigger == first_left
                    respTrigger = second_right;
                    
                    if eyetracker
                        % SEND RESPONSE's TRIGGER
%                         WriteParPort(respTrigger)
%                         WaitSecs(0.003) % in seconds; use minium samplingRate x2, usually x3
%                         WriteParPort(0)
                        Eyelink('Message', ['Trigger ' num2str(respTrigger)])
                        WaitSecs(0.003)
                    else
                        simulate_respCheck.second_respTrigger(1,istim) = respTrigger;
                    end
                    
                end
                
            end
            
            
            % Is this a pilot session with simulated responses?
            if isRobot
                % simulate participant response (1st click around 0.5 and
                % 2nd around 1s)
                if round(tstim - tstartScene, 1) == 0.5 && ~previousChoice
                    if robotResp == 1
                        rob.keyPress(KeyEvent.VK_Y)
                    elseif robotResp == 2
                        rob.keyPress(KeyEvent.VK_B)
                    end
                    simulate_respCheck.firstRT(1,istim) = GetSecs - tstartScene;
                    
                    
                elseif round(tstim - tstartScene, 1) == 0.8 && previousChoice && chResp
                    if robotResp == 1
                        rob.keyRelease(KeyEvent.VK_Y)
                        rob.keyPress(KeyEvent.VK_B)
                        simulate_respCheck.secondRT(1,istim) = GetSecs - tstartScene;
                    elseif robotResp == 2
                        rob.keyRelease(KeyEvent.VK_B)
                        rob.keyPress(KeyEvent.VK_Y)
                        simulate_respCheck.secondRT(1,istim) = GetSecs - tstartScene;
                    end
                    
                end
            end
            
            %answerTime = GetSecs - tstartScene - tpreptotal;
            answerTime = answerTime_abs - tstartScene;
            
            % calculate remaining time
            time = timeStim - answerTime;
            
            % position of the images
            patchrct = [0 0 video.x/2 video.y];
            patchrct2 = [video.x/2 0 video.x video.y];
            
            % here before there was an if loop to flip the images
            % differently for males and females
            %1st actor male
            patchtex = Screen('MakeTexture',video.h,img,[],[],1);
            Screen('DrawTexture',video.h,patchtex,[],patchrct);
            
            %2nd actor male
            patchtex = Screen('MakeTexture',video.h,img2,[],[],1);
            Screen('DrawTexture',video.h,patchtex,[],patchrct2);
            
            %cross
            patchtex = Screen('MakeTexture',video.h,cross,[],[],[]);
            patchrct = CenterRectOnPoint(Screen('Rect',patchtex),video.x/2,video.y/2-(video.y*0.3611));
            Screen('DrawTexture',video.h,patchtex,[],patchrct);
            
            % ------------------------------------------------------------------------------------------------%
            %           IN CASE OF LEFT RESPONSE FOR NORMAL TRIALS, OR RIGHT RESPONSE FOR REVERSE ONES
            % ------------------------------------------------------------------------------------------------%
            
            % (if 'left button' is down and not 'right button' and this is NOT a reverse item ) OR (if 'right button' is down and not 'left button' and this is a reverse item)...
            if ((answerButton == 1 && answerButton ~= 2 && ~reverse) || (answerButton ~= 1 && answerButton == 2 && reverse)) && leftAutorization
                if hesitation || previousChoice ~= 1
                    distance = sqrt((dot(1)-target.left(1)).^2 + (dot(2)-target.left(2)).^2);
                    drawSpeed = (coeffm*distance) / (coeffs*time);
                end
                
                if previousChoice ~= 1
                    response(istim).nbChoices = 1 + response(istim).nbChoices;
                    previousChoice = 1;
                elseif hesitation && previousChoice == 1 && response(istim).firstChoice ~= 0
                    response(istim).nbHesitations = response(istim).nbHesitations + 1;
                end
                hesitation = false;
                
                if response(istim).nbChoices == 1
                    response(istim).timeRelease = answerTime; % don't know what this is
                end
                
                % save the time and the choice for the answer
                if response(istim).firstChoice == 0
                    
                    response(istim).timeFirstChoice = answerTime;
                    
                    if reverse
                        response(istim).firstChoice = 2;
                    else
                        response(istim).firstChoice = 1;
                    end
                    
                elseif (response(istim).secondChoice == 0) && (response(istim).nbChoices == 2)
                    
                    response(istim).timeSecondChoice = answerTime;
                    if reverse
                        response(istim).secondChoice = 2;
                    else
                        response(istim).secondChoice = 1;
                    end
                    response(istim).timeBetweenAnswers = answerTime - response(istim).timeFirstChoice;
                    response(istim).timeReleasePress = answerTime - response(istim).timeRelease;
                end
                
                %save dot position
                response(istim).dot(1, 1) = dot(1);
                response(istim).dot(1, 2) = dot(2);
                
                %...draw a dot towards left
                Screen('DrawDots', video.h, dot, dotSize, [255 0 0 1]);
                
                %update dot coord
                dot = nextpoint(dot, target.left, dot(1)-drawSpeed);
                %indicate the last choice is left
                
                if response(istim).nbChoices > 1
                    rightAutorization = false;
                end
                
                response(istim).resp = 1;
                
                % ------------------------------------------------------------------------------------------------%
                %           IN CASE OF RIGHT RESPONSE FOR NORMAL TRIALS, OR LEFT RESPONSE FOR REVERSE ONES
                % ------------------------------------------------------------------------------------------------%
                % else (if 'M' is down and not 'Q' and this is NOT a reverse item ) OR (if 'Q' is down and not 'M' and this is a reverse item)...
            elseif ((answerButton == 2 && answerButton ~= 1 && ~reverse) || (answerButton ~= 2 && answerButton == 1 && reverse)) && rightAutorization
                
                if hesitation || previousChoice ~= 2
                    distance = sqrt((dot(1)-target.right(1)).^2 + (dot(2)-target.right(2)).^2);
                    drawSpeed = (coeffm*distance) / (coeffs*time);
                end
                
                if previousChoice ~= 2
                    response(istim).nbChoices = 1 + response(istim).nbChoices;
                    previousChoice = 2;
                elseif hesitation && previousChoice == 2 && response(istim).firstChoice ~= 0
                    response(istim).nbHesitations = response(istim).nbHesitations + 1;
                end
                hesitation = false;
                
                if response(istim).nbChoices == 1
                    response(istim).timeRelease = answerTime; % don't know what this is
                end
                
                if response(istim).firstChoice == 0
                    
                    response(istim).timeFirstChoice = answerTime;
                    
                    if reverse
                        response(istim).firstChoice = 1;
                    else
                        response(istim).firstChoice = 2;
                    end
                    
                elseif (response(istim).secondChoice == 0) && (response(istim).nbChoices == 2)
                    response(istim).timeSecondChoice = answerTime;
                    if reverse
                        response(istim).secondChoice = 1;
                    else
                        response(istim).secondChoice = 2;
                    end
                    response(istim).timeBetweenAnswers = answerTime - response(istim).timeFirstChoice;
                    response(istim).timeReleasePress = answerTime - response(istim).timeRelease;
                end
                
                %save dot position
                response(istim).dot(2, 1) = dot(1);
                response(istim).dot(2, 2) = dot(2);
                
                %...draw a dot towards right
                Screen('DrawDots', video.h, dot, dotSize, [255 0 0 1]);
                
                %update coord for dots and neutral line
                dot = nextpoint(dot, target.right, dot(1)+drawSpeed);
                
                if response(istim).nbChoices > 1
                    leftAutorization = false;
                end
                
                response(istim).resp = 2;
                
                % else if the 2 keys are down is the same time or if anykey is down...
            else
                if ~hesitation
                    distance = dot(2)-target.left(2);
                    drawSpeed = (coeffm*distance) / (coeffs*time);
                end
                
                %save dot position
                response(istim).dot(3, 1) = dot(1);
                response(istim).dot(3, 2) = dot(2);
                
                %... draw a neutral dot
                Screen('DrawDots', video.h, dot, dotSize, [255 0 0 1]);
                
                %update coord for nexts dots and neutral line
                dot(2) = dot(2)-drawSpeed;
                
                %indicate the last choice is neutral
                hesitation = true;
                
                response(istim).resp = 0;
            end
            
            tflip = Screen('Flip',video.h);
            WaitSecs(video.ifi)
            % tflip = GetSecs;
            
            if tpreptotal == 0
                tpreptotal = tflip-tstim;
            end
            if CheckKeyPress(keyquit)
                aborted = true;
                
                % is this a session with simulated resposnes?
                if isRobot
                    % release robot press
                    if (robotResp == 1 && ~chResp) || (robotResp == 2 && chResp)
                        rob.keyRelease(KeyEvent.VK_Y)
                    elseif (robotResp == 2 && ~chResp) || (robotResp == 1 && chResp)
                        rob.keyRelease(KeyEvent.VK_B)
                    end
                end
            
                break;
            end
        end
        
        % is this a session with simulated resposnes?
        if isRobot
            % release robot press
            if (robotResp == 1 && ~chResp) || (robotResp == 2 && chResp)
                rob.keyRelease(KeyEvent.VK_Y)
            elseif (robotResp == 2 && ~chResp) || (robotResp == 1 && chResp)
                rob.keyRelease(KeyEvent.VK_B)
            end
        end
        
        
        %calcul scene
        tstimcheck.scene(istim)= tflip - tstartScene;
        if aborted
            break;
        end
        
        %enregistre la nature de la réponse
        response(istim).iscor = (response(istim).resp == 1 || response(istim).resp == 2 );
        
        %% si rep sur siege, affichage face pdt 300ms, sinon rappel des consignes
        if response(istim).iscor
            
            % same position as before
            patchrct = [0 0 video.x/2 video.y];
            patchrct2 = [video.x/2 0 video.x video.y];
            
            % here before there was an if loop to flip the images
            % differently for males and females
            
            %1st actor male
            patchtex = Screen('MakeTexture',video.h,img,[],[],1);
            Screen('DrawTexture',video.h,patchtex,[],patchrct);
            
            %2nd actor male
            patchtex = Screen('MakeTexture',video.h,img2,[],[],1);
            Screen('DrawTexture',video.h,patchtex,[],patchrct2);
            
            %cross
            patchtex = Screen('MakeTexture',video.h,cross,[],[],[]);
            patchrct = CenterRectOnPoint(Screen('Rect',patchtex),video.x/2,video.y/2-(video.y*0.3611));
            Screen('DrawTexture',video.h,patchtex,[],patchrct);
            
            patchtex = Screen('MakeTexture',video.h,part,[],[],1);
            if response(istim).resp == 1
                patchrct = CenterRectOnPoint(Screen('Rect',patchtex),target.left(1), video.y-target.left(2)); % changer coordonées video.x/2-500,video.y/2-150
            else
                patchrct = CenterRectOnPoint(Screen('Rect',patchtex),target.right(1), video.y-target.right(2));
            end
            Screen('DrawTexture',video.h,patchtex,[],patchrct);
            Screen('Flip',video.h); %affichage scene+cross
        else
            labeltxt = 'ESSAI INCORRECT !';
            labelrec = CenterRectOnPoint(Screen('TextBounds',video.h,labeltxt),video.x/2,video.y/5);
            Screen('DrawText',video.h,labeltxt,labelrec(1),labelrec(2),1);
            
            Screen('DrawingFinished',video.h);
            Screen('Flip', video.h);
            WaitSecs(0.5)
        end
        
        %save answer by category
        cresponse.firstChoice(1,istim) = response(istim).firstChoice;
        cresponse.timeFirstChoice(1,istim) = response(istim).timeFirstChoice;
        cresponse.secondChoice(1,istim) = response(istim).secondChoice;
        cresponse.timeSecondChoice(1,istim) = response(istim).timeSecondChoice;
        cresponse.timeBetweenAnswers(1,istim) = response(istim).timeBetweenAnswers;
        cresponse.timeGreyCross(1,istim) = response(istim).timeGreyCross;
        cresponse.dot(:, :, istim) = response(istim).dot(:,:);
        cresponse.nbHesitations(1,istim) = response(istim).nbHesitations;
        cresponse.nbChoices(1,istim) = response(istim).nbChoices;
        cresponse.timeRelease(1,istim) = response(istim).timeRelease;
        cresponse.timeReleasePress(1,istim) = response(istim).timeReleasePress;
        cresponse.iscor(1,istim) = response(istim).iscor;
        cresponse.resp(1,istim) = response(istim).resp;
        
        
        %load ecran gris
        patchtex = Screen('MakeTexture',video.h,img_greyscreen,[],[],1);
        patchrct = CenterRectOnPoint(Screen('Rect',patchtex),video.x/2,video.y/2);
        Screen('DrawTexture',video.h,patchtex,[],patchrct);
        t1=GetSecs;
        Screen('Flip',video.h,t1+0.300); %affichage ecran gris+cross
        Screen('Close');
        
    end
    
    if eyetracker
        Eyelink.StopRecording(sprintf('S%02d_bl%d',sid,ibloc),'..\data\eyelinkData\')
    end
        

    if ~aborted
        
        maccur = mean(cresponse.iscor == 1);
        mspeed = mean(cresponse.timeFirstChoice(cresponse.iscor == 1));
        
        labeltxt = {};
        labelrec = [];
        labeltxt{1} = sprintf('Précision : %.0f %%',maccur*100);
        labelrec(1,:) = CenterRectOnPoint(Screen('TextBounds',video.h,labeltxt{1}),video.x/2,video.y/2- (0.03*video.y));
        labeltxt{2} = sprintf('Rapidité : %.0f ms',mspeed*1000);
        labelrec(2,:) = CenterRectOnPoint(Screen('TextBounds',video.h,labeltxt{2}),video.x/2,video.y/2+ (0.03*video.y));
        labelrec(2,:) = AlignRect(labelrec(2,:),labelrec(1,:),'left');
        framerec = [min(labelrec(:,1))-round(32),min(labelrec(:,2))-round(32),max(labelrec(:,3))+round(32),max(labelrec(:,4))+round(32)];

        Screen('FrameRect',video.h,1,framerec,3);
        Screen('DrawText',video.h,labeltxt{1},labelrec(1,1),labelrec(1,2),1);
        Screen('DrawText',video.h,labeltxt{2},labelrec(2,1),labelrec(2,2),1);
        Screen('DrawingFinished',video.h);
        
        Screen('Flip',video.h);
        WaitSecs(5);
        Screen('Flip',video.h);
        
    end
    
    if aborted
        Priority(0);
        Screen('CloseAll');
        FlushEvents;
        ListenChar(0);
        ShowCursor;
        return
    end
    
    % old block end was here
    
    Priority(0);
    Screen('CloseAll');
    FlushEvents;
    ListenChar(0);
    ShowCursor;
    
catch
    
    Priority(0);
    Screen('CloseAll');
    FlushEvents;
    ListenChar(0);
    ShowCursor;
    
    rethrow(lasterror);
    
    if eyetracker
        Eyelink.StopRecording(sprintf('S%02d_bl%d',sid,ibloc),'..\data\eyelinkData\')
    end
    
end
end