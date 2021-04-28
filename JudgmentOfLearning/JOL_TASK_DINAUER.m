% FINAL_DINAUER_C.m
%
% This program runs a free recall task, in which participants must make
% Judgments of Learning (JOLs) for how likely they think they are to 
% recall words on a later recall test. The research question is: "Will
% people make more accurate JOLs that are reflective of the Serial Position
% effect if they make a JOL before or after a word is presented? Does 
% font size influence our JOLs and actual recall?"
% 
% Two Independent Variables:
%  1) When JOL is Made: Before Word Presentation vs After Word Presentation
%  2) Font Size: Words are Same Size vs Words are Different Sizes
%
% Dependent Variables:
%  1) JOLs made on each trial (percentage of 0 to 100)
%  2) Actual recall of words  (percentage of 0 to 100)
% 
% Conditions are as follows:
%  - Condition 1: JOLs are made after each word and font size is constant
%  - Condition 2: JOLs are made after each word and font size is varied
%  - Condition 3: JOLs are made before each word and font size is constant
%  - Condition 4: JOLs are made before each word and font size is varied
%  - Condition 5: JOLs are made before each word, font size is constant, and position number is included
%  - Condition 6: JOLs are made before each word, font size is varied, and position number is included
% 
% Written by Claire Dinauer
% Last edited on June 10, 2020
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Screen('Preference', 'SkipSyncTests', 1);
Screen('Preference','VisualDebugLevel', 0);

try
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                 %% SETUP %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear;                   % clearing variables in the workspace
close all;               % closing the figure windows
AssertOpenGL;            % for displaying stimuli
KbName('UnifyKeyNames'); % ensuring psychtoolbox recognizes keys
rng shuffle;             % shuffling the random number generator

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                      %% COLLECT DEMOGRAPHIC INFO %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Creating a inputdlg box:
subjectInfo = {'Initials:','Age:','Gender:','Hours of Sleep:',...
        'Alertness (1-10):'};             % fields to fill in
boxTitle = 'Participant Information';     % title of the input box
numLines = 1;                             % number of lines set to one
subjInput = inputdlg(subjectInfo,boxTitle,numLines);
    
% Saving subject's demographic info in Results cell array
Results.subjInitials = subjInput{1};          % save as string
Results.subjAge = str2double(subjInput{2});   % save as number
Results.subjGender = subjInput{3};            % save as string
Results.subjSleep = str2double(subjInput{4}); % save as number
Results.subjAlert = str2double(subjInput{5}); % save as number

% Recording the date and creating the SubjectID:
participationDate = date;
Results.SubjectID = horzcat(participationDate, Results.subjInitials);

    % we can extract out the ID from the subjInfo cell array and use that
    % as a part of our file name for saving data
    % savename = ['myExperiment_' Results.ID '.mat'];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                          %% DEFINE PARAMETERS %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% DEFINING COLORS %%
WHITE = [255 255 255];
BLACK = [0 0 0];
LIGHTBLUE = [165 220 250];
ORANGE = [255 175 100];

%% DEFINING VELOCITY FOR ANIMATION %% 
velocity = 6;

%% READING IN IMAGE OF THE LOGO %%
logo = imread('DinauerMatlabLogo.jpg'); 

%% DEFINING VECTOR OF WORDS TO DISPLAY %%
% 288 total words (6 conditions with 4 trials each and 12 words per trial)
% Each word has 2 syllables and are similar in length (5 to 7 letters)
words = readcell('words.txt')'; % read words into cell array

%% DEFINING IMPORTANT NUMBERS OF THE EXPERIMENT %%
nConditions = 6;        % number of conditions
nListsPerCondition = 4; % number of word lists (trials) per condition
listLength = 12;        % number of words in each list

%% DEFINE THE INSTRUCTIONS TO DISPLAY BETWEEN EACH CONDITION %%
% Welcome Page Instructions
welcomePage = ['Welcome!\n\n This is a word memory task. Your participation '...
    'is helpful to understand the roles of\n intrinsic and extrinsic factors '...
    'when encoding information and when making predictions\n about how well '...
    'we can estimate our learning.\n\n'...
    'This study will take about 30 minutes to complete,\n and there '...
    'are no risks to participating other than potential boredom.\n\n'...
    'If necessary, you may exit the study by pressing the Escape key on your '...
    'keyboard once a full list has been presented.\n\n '...
    'Press any key when you are ready for the study instructions.'];
% Experiment Instructions
welcomeInstructions = ['In each of the following tasks, you will be presented '...
    'with a list of twelve words.\n After each list is displayed, do your '...
    'best to recall as many words from the list as you can on the ''Recall'' page.\n\n'...
    'When recalling words, put a SPACE between each word. No commas please.\n'...
    'Press ENTER after recalling all the words you can.\n'...
    'If you press ''enter'' before intended, you can not go back.\n\n'...
    'Before or after each word is presented, you will be asked '...
    'to make a Judgment of Learning (JOL) between 0 and 100.\n '...
    'A Judgment of Learning is an indication of how well you think you '...
    'will remember a word in a later recall test.\n\n There will be '...
    'a total of 24 lists of words. Hence, you will be making a total '...
    'of 288 JOLs.\n\n Feel free to take breaks when recommended by the study.\n\n'...
    'Press any key when you are ready for the first list of words.'];
% Task-Specific Instructions:
condition1Instructions = ['For the next four lists, you will be asked to\n'...
    'make a Judgment of Learning after each word is presented.\n\n'...
    'Font size of the words will be consistent.\n\n'...
    'Feel free to take a break now before beginning.\n Press any key when you are ready.'];
condition2Instructions = ['For the next four lists, you will be asked to\n'...
    'make a Judgment of Learning after each word is presented.\n\n'...
    'Font size of the words will vary: half small, half large.\n\n'...
    'Feel free to take a break now before beginning.\n Press any key when you are ready.'];
condition3Instructions = ['For the next four lists, you will be asked to\n'  ...
    'make a Judgment of Learning before each word is presented.\n\n'...
    'Font size of the words will be consistent.\n\n'...
    'Feel free to take a break now before beginning.\n Press any key when you are ready.'];
condition4Instructions = ['For the next four lists, you will be asked to\n'...
    'make a Judgment of Learning before each word is presented.\n\n'...
    'Font size of the words will vary: half small, half large.\n\n'...
    'Feel free to take a break now before beginning.\n Press any key when you are ready.'];
condition5Instructions = ['For the next four lists, you will be asked to\n'...
    'make a Judgment of Learning before each word is presented.\n\n'...
    'Font size of the words will be consistent.\n\n'...
    'Feel free to take a break now before beginning.\n Press any key when you are ready.'];
condition6Instructions = ['For the next four lists, you will be asked to\n '...
    'make a Judgment of Learning before each word is presented.\n\n'...
    'Font size of the words will vary: half small, half large.\n\n'...
    'Feel free to take a break now before beginning.\n Press any key when you are ready.'];
% Asking the participant to make a JOL        
predictionJOL = ['Prediction of likelihood of recall?\n Scale of 0 to 100:\n'];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %% SET UP SCREEN %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
screens=Screen('Screens');
scrnNum=max(screens); % gives the screen number
                    
[window, rect] = Screen('OpenWindow',scrnNum,WHITE); % open window

[cx, cy] = RectCenter(rect);      % central x and y locations
[width, height] = RectSize(rect); % width and height of the opened window
Screen('TextSize', window,20);          % set font size to 20
Screen('TextStyle',window,1);           % bolden text

% begin showing what we draw 
Screen('Flip',window);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                           %% SET UP AUDIO PORT %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
audioSampleRate  = 16000; 
numAudioChannels = 1;
InitializePsychSound(1);
audioPort = PsychPortAudio('Open', [], [], [], audioSampleRate, numAudioChannels);

% DEFINE SOUND
[boingTemp, boingSampleRate] = audioread('boing.wav'); % defining boing sound
boing = boingTemp';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                           %% SET UP STIMULI %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% RANDOMIZE THE WORDS AND SORT INTO 24 LISTS %%
% first randomize the words
randWords = words(randperm(length(words))); 
% next, assign 12 words to each list for conditions 1 to 6
% lists for condition 1
list1 = randWords(:,1:12);     list2 = randWords(:,13:24); 
list3 = randWords(:,25:36);    list4 = randWords(:,37:48); 
% lists for condition 2
list5 = randWords(:,49:60);    list6 = randWords(:,61:72);
list7 = randWords(:,73:84);    list8 = randWords(:,85:96);
% lists for condition 3
list9 = randWords(:,97:108);   list10 = randWords(:,109:120);
list11 = randWords(:,121:132); list12 = randWords(:,133:144);
% lists for condition 4
list13 = randWords(:,145:156); list14 = randWords(:,157:168);
list15 = randWords(:,169:180); list16 = randWords(:,181:192);
% lists for condition 5
list17 = randWords(:,193:204); list18 = randWords(:,205:216);
list19 = randWords(:,217:228); list20 = randWords(:,229:240);
% lists for condition 6
list21 = randWords(:,241:252); list22 = randWords(:,253:264);
list23 = randWords(:,265:276); list24 = randWords(:,277:288);

%% ADD SERIAL POSITION TO WORDS IN CONDITION 5 AND CONDITION 6 %%
% Serial numbers to be displayed on the prediction screen
predictionSerialNumber = {'1.','2.','3.','4.','5.','6.','7.','8.','9.','10.','11.','12.'};

% I created a serialNumber function in serialNumber.m, which adds the 
% serial number to each word in a list.  
% Condition 5:
serialList17 = serialNumber(list17);
serialList18 = serialNumber(list18);
serialList19 = serialNumber(list19);
serialList20 = serialNumber(list20);
% Condition 6:
serialList21 = serialNumber(list21);
serialList22 = serialNumber(list22);
serialList23 = serialNumber(list23);
serialList24 = serialNumber(list24);

%% RANDOMIZE LARGE VS SMALL FONTS %%
% Randomize which words will be in a small font versus large font for
% Condition 2, Condition 4, and Condition 6 (font size is consistent for
% the other three conditions).

% Initialize fontConditions as a 12x12 matrix
% - Rows 1-4 are Condition 2 font orders for lists 5-8
% - Rows 5-8 are Condition 4 font orders for lists 13-16
% - Rows 8-12 are Condition 6 font orders for lists 21-24
fontConditions = [0 0 0 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0 0 0 0 0;... 
    0 0 0 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0 0 0 0 0; ...
    0 0 0 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0 0 0 0 0;...
    0 0 0 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0 0 0 0 0];
numVariedFontLists = 12; % number of lists with varied font
                         
% This for loop randomly assigns small or large font condition order                         
for i = 1:numVariedFontLists
    randTwelve = randperm(12);                   % randomize numbers 1-12
    twelvePlaces = [1,1,1,1,1,1,2,2,2,2,2,2];    % 1s are small font
                                                 % 2s are large font
    % newTwelvePlaces indicates which words will be which size font
    newTwelvePlaces = [0,0,0,0,0,0,0,0,0,0,0,0]; 
    for j = 1:12
        % assign the randomized orders of the large vs small fonts
        newTwelvePlaces(j) = twelvePlaces(randTwelve(j)); 
    end
    fontConditions(i,:) = newTwelvePlaces;
    % Each row of fontConditions will be the order of large vs small fonts
    % for Condition 2, Condition 4 and Condition 6.
end

%% INITIALIZE SMALL VS LARGE FONT JOL MATRIX %%
% In order to collect data regarding whether people's predictions change
% when they know the font size of a word (intrinsic factor), I am
% initializing matricies to keep track of participants' JOLs for small font
% versus large font words and based on whether they make a JOL after
% seeing a word (Condition 2) or before seeing a word (Conditions 4 and 6).

% CONDITION 2: Post-JOLs
% Create matrix to record JOLs made AFTER seeing a word in SMALL font 
smallFontPostJOL = [0 0 0 0 0 0; 0 0 0 0 0 0; 0 0 0 0 0 0; 0 0 0 0 0 0];
% Create matrix to record JOLs made AFTER seeing a word in LARGE font 
largeFontPostJOL = [0 0 0 0 0 0; 0 0 0 0 0 0; 0 0 0 0 0 0; 0 0 0 0 0 0];

% CONDITION 4 AND 6: Pre-JOLs
% Create matrix to record JOLs made BEFORE seeing a word in SMALL font 
smallFontPreJOL4 = [0 0 0 0 0 0; 0 0 0 0 0 0; 0 0 0 0 0 0; 0 0 0 0 0 0];
smallFontPreJOL6 = [0 0 0 0 0 0; 0 0 0 0 0 0; 0 0 0 0 0 0; 0 0 0 0 0 0];
% Create matrix to record JOLs made BEFORE seeing a word in LARGE font 
largeFontPreJOL4 = [0 0 0 0 0 0; 0 0 0 0 0 0; 0 0 0 0 0 0; 0 0 0 0 0 0];
largeFontPreJOL6 = [0 0 0 0 0 0; 0 0 0 0 0 0; 0 0 0 0 0 0; 0 0 0 0 0 0];

%% BEGIN COUNT FOR NUMBER OF SMALL WORDS AND LARGE WORDS RECALLED %%
smallFontRecall = 0;
largeFontRecall = 0;
% In total, there are 72 small words and 72 large words in the varying font
% conditions. I will add 100 to smallFontRecall when a small font word is 
% correctly recalled, and add 100 to largeFontRecall when a large font word
% is correctly recalled. 
% At the end, I will divide each by 72 to get the percentage of small words 
% recalled and percentage of large words recalled.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                   %% WELCOME AND INSTRUCTIONS PAGES %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% DISPLAY THE LOGO AND PLAY SOUND %%
% get the dimensions of the image
logoDim = size(logo); 
% layers dimensions
logoHeight = logoDim(1); % height of the image
logoWidth = logoDim(2);  % width of the image
% resizing our image to .85 scale by going through each layer
for i = 1:2 
    if i == 1
        scaledLogo = imresize(logo,.85); % specify .85 scale
    elseif i == 2
        scaledLogo = imresize(logo,[(.85*logoHeight) (.85*logoWidth)]); 
    end
end
% Make a texture of newly scaled logo image
logoTex = Screen('MakeTexture',window,scaledLogo);
% Draw to the screen for 6 seconds
Screen('DrawTexture',window,logoTex);
Screen('Flip',window); 
PsychPortAudio('FillBuffer', audioPort, boing);
PsychPortAudio('Start', audioPort);   % play boing audio
PsychPortAudio('Stop', audioPort, 1); % stop when finished
WaitSecs(5);

%% WELCOME PAGE WITH ANIMATED DOTTED BACKGROUND %% 
% Create an array of dots for the background
presTime = 4; % set presentation time to 5 seconds
dotShape = 1;  % makes the dots circular
dotSize = 20;   % set dot size to 8

startTime = GetSecs;                 % get startTime to use for while-loop
while GetSecs - startTime < presTime % Create an array of dots
    xDots = linspace(1, width-1, 25) ; % x-coordinates for dots
    xDots = repmat(xDots,1,25); % repeat 60 times to fill the screen
    yDots = linspace(1, height-1,25); 
    yDots = repelem(yDots,1,25); % repelem repeats each element 60 times 
    % Pair each x location with each y location
    dotXY = [xDots ; yDots];
    % Draw dots and put them on the screen
    Screen('DrawDots', window, dotXY, dotSize, LIGHTBLUE, [], dotShape);
    DrawFormattedText(window, 'Welcome to the experiment!', 'center','center',BLACK,[],[],[],1.5);
    Screen('Flip', window);
    
    % repeat the above code several times to make a somewhat smooth
    % motion of the shapes moving upward:
    for i = 1:7
        yDots = yDots - velocity; % dots shift on y-axis based on velocity
        dotXY = [xDots; yDots];
        % draw the moved dots to the screen
        Screen('DrawDots', window, dotXY, dotSize, LIGHTBLUE, [], dotShape);
        % Welcome the participant to the experiment
        DrawFormattedText(window, 'Welcome to the experiment!', 'center','center',BLACK,[],[],[],1.5);
        Screen('Flip', window); 
    end
end
WaitSecs(0.1);

%% INFORMATIONAL WELCOME AND INSTRUCTIONS PAGES %%
% Draw the welcome page to the window
Screen('TextSize', window,20); % Set font size back to 20
DrawFormattedText(window, welcomePage,'center','center',BLACK,[],[],[],1.5);
Screen('Flip',window);
WaitSecs(0.3+rand*0.3);
startTime = GetSecs;      % getting computer time at this moment
[secs, keyCode] = KbWait; % wait for keypress for participant to continue
responseTime = secs - startTime; % recording response time

% Draw the instructions to the window
DrawFormattedText(window, welcomeInstructions,'center','center',BLACK,[],[],[],1.5);
Screen('Flip',window);
WaitSecs(0.3+rand*0.3);
startTime = GetSecs;      % getting computer time at this moment
[secs, keyCode] = KbWait; % wait for keypress for participant to continue
responseTime = secs - startTime; % recording response time

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                       %% RUNNING THE EXPERIMENT %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RANDOMIZE PRESENTATION ORDER OF CONDITIONS
conditionOrder = randperm(6);
conditionOrder = [conditionOrder 7];

% Run the study in a while loop, and allow the participant to exit the
% study by pressing the "escape" key
exitNow = false;
while ~exitNow
  for c = 1:(nConditions+1) % add 1 since we are including an exit screen
    if conditionOrder(c) == 1 % run condition 1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%% CONDITION 1 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% JOLs are made after each word and font size is constant %%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% INITIALIZING WORD LISTS, PREDICTED JOLS, AND ACTUAL RECALL %%
% Combine Lists 1-4 for Display
condition1Lists = [list1; list2; list3; list4];

% Initialize Predicted JOLs Vector for Condition 1
predictedJOLs1 = [0 0 0 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0 0 0 0 0;...
    0 0 0 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0 0 0 0 0];

% Initialize Actual Recall Vector of Participant
% - If a word is correctly recalled from the list, then the user gets "100"
%   for the word in that serial position. 
% - If a word is not recalled/incorrectly recalled, then the user gets a "0"
%   for the word in that serial position.
actualRecall1 = [0 0 0 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0 0 0 0 0;...
    0 0 0 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0 0 0 0 0];

%% INTRODUCING THE TASK/CONDITIONS WITH BACKGROUND RECTANGLES
% Drawing Two Rectangles (one on top of other):
Screen('Flip',window);
rectangleRect = [cx-400 cy-250 cx+400 cy+250] ; % coordinates for top left and bottom right 
Screen('FillRect', window, ORANGE, rectangleRect); % draw filled rectangle
rectangleRect = [cx-300 cy-200 cx+300 cy+200] ; % coordinates for top left and bottom right 
Screen('FillRect', window, LIGHTBLUE, rectangleRect); % draw filled rectangle
% Drawing Instructions on top of the rectangles:
Screen('TextSize', window,20);
DrawFormattedText(window, condition1Instructions,'center','center',BLACK  );
Screen('Flip',window);
WaitSecs(0.3+rand*0.3);
startTime = GetSecs;      % getting computer time at this moment
[secs, keyCode] = KbWait; % wait for keypress for participant to continue
responseTime = secs - startTime; % recording response time

%% DISPLAYING THE WORD LIST AND ASKING FOR JOL AFTER EACH WORD %%
startTime1 = GetSecs; % get start time at beginning of condition
for i = 1:nListsPerCondition
    list = condition1Lists(i, :);       % clarify list of words
    
    for j = 1:listLength
        % DISPLAY WORD:
        word = list{j};                 % get each word of the list
        Screen('TextSize', window,40);  % set font size to 40
        DrawFormattedText(window, word,'center','center',BLACK);
        Screen('Flip',window);          % displaying the word for 2 secs
        WaitSecs(2);
        % GET JOL FOR WORD:
        Screen('TextSize', window,30);  
        DrawFormattedText(window, predictionJOL,'center','center',BLACK);
        number = str2double(GetEchoString(window, '',cx-10,cy+35,BLACK,WHITE,[],[],20,[]));
        Screen('Flip',window);
        predictedJOLs1(i,j) = number; % add JOL for word to predictedJOLs
        Screen('Flip',window);
    end

    %% ASK USER TO RECALL WORDS FROM PRIOR LIST
    Screen('Flip',window);
    Screen('TextSize', window,30);
    % Use GetEchoString so user can see what they are typing while recalling words
    [string,terminatorChar] = GetEchoString(window,'Recall: ',10,cy,BLACK,WHITE,[],[],20,[]);

    % I made a function called userRecall, which separates each word recalled
    % by the user into a cell array to be used to compare to the original list.
    recalledWords = userRecall(string);

    %% ACTUAL RECALL DATA
    % - If a word is correctly recalled from the list, then the user gets "100"
    %   for the word in that serial position. 
    % - If a word is not recalled/incorrectly recalled, then the user gets a "0"
    %   for the word in that serial position.
    for k = 1:length(recalledWords)
        if ~any(strcmp(list,recalledWords{k}))
            actualRecall1(i,k) = 0; % if a word was not recalled or recalled incorrectly 
        else
            indexList = strfind(list,recalledWords(k));
            index = find(not(cellfun('isempty',indexList)));
            actualRecall1(i,index) = 100;
        end
    end

    %% ASK USER TO PRESS ANY KEY TO BEGIN NEXT LIST
    if i ~= nListsPerCondition
        Screen('Flip',window);
        DrawFormattedText(window, 'Press any key to begin the next list.','center','center',BLACK,[],[],[],1.5);
        Screen('Flip',window);
        WaitSecs(0.3+rand*0.3);
        startTime = GetSecs;      % getting computer time at this moment
        [secs, keyCode] = KbWait; % wait for keypress for participant to continue
        responseTime = secs - startTime; % recording response time
    end
end
endTime1 = GetSecs; % get end time after condition is complete
responseTime1 = endTime1 - startTime1; % calculate response time for condition


elseif conditionOrder(c) == 2 % run condition 2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%% CONDITION 2 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% JOLs are made after each word and font size is varied %%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% INITIALIZING WORD LISTS, PREDICTED JOLS, AND ACTUAL RECALL %%
% Combine Lists 5-8 for Display
condition2Lists = [list5; list6; list7; list8];
% Initialize Predicted JOLs Vector for Condition 2
predictedJOLs2 = [0 0 0 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0 0 0 0 0;...
    0 0 0 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0 0 0 0 0];
% Initialize Actual Recall Vector of Participant
actualRecall2 = [0 0 0 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0 0 0 0 0;...
    0 0 0 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0 0 0 0 0];
% Initialize smallFontIndex and largeFontIndex to record JOLs based on font
smallFontIndex = 1;
largeFontIndex = 1;

%% INTRODUCING THE TASK/CONDITIONS
% Drawing Two Rectangles (one on top of other):
Screen('Flip',window);
rectangleRect = [cx-400 cy-250 cx+400 cy+250] ; % coordinates for top left and bottom right 
Screen('FillRect', window, ORANGE, rectangleRect); % draw filled rectangle
rectangleRect = [cx-300 cy-200 cx+300 cy+200] ; % coordinates for top left and bottom right 
Screen('FillRect', window, LIGHTBLUE, rectangleRect); % draw filled rectangle
% Drawing Instructions on top of the rectangles:
Screen('TextSize', window,20);
DrawFormattedText(window, condition2Instructions,'center','center',BLACK);
Screen('Flip',window);
WaitSecs(0.3+rand*0.3);
startTime = GetSecs;      % getting computer time at this moment
[secs, keyCode] = KbWait; % wait for keypress for participant to continue
responseTime = secs - startTime; % recording response time

%% DISPLAYING THE WORD LIST AND ASKING FOR JOL AFTER EACH WORD %%
startTime2 = GetSecs; % get start time at beginning of condition
for i = 1:nListsPerCondition
    list = condition2Lists(i, :);       % clarify list of words
    
    for j = 1:listLength
        % SET FONT SIZE OF WORD
        if fontConditions(i,j)==1
            Screen('TextSize', window,20); % set small font
        elseif fontConditions(i,j)==2
            Screen('TextSize', window,75); % set large font
        end
        % DISPLAY WORD:
        word = list{j}; % get each word of the list
        DrawFormattedText(window, word,'center','center',BLACK);
        Screen('Flip',window);         
        WaitSecs(2);  % displaying the word for 2 secs
        % GET JOL FOR WORD:
        Screen('TextSize', window,30);  
        DrawFormattedText(window, predictionJOL,'center','center',BLACK);
        number = str2double(GetEchoString(window, '',cx-10,cy+35,BLACK,WHITE,[],[],20,[]));
        Screen('Flip',window);
        predictedJOLs2(i,j) = number; % add JOL for word to predictedJOLs
        Screen('Flip',window);
        % RECORD JOL BASED ON FONT SIZE
        if fontConditions(i,j)==1
            smallFontPostJOL(i,smallFontIndex) = number;
            smallFontIndex = smallFontIndex+1;
        elseif fontConditions(i,j)==2
            largeFontPostJOL(i,largeFontIndex) = number;
            largeFontIndex = largeFontIndex+1;
        end
        % RESET FONT INDEX IF EQUAL TO 7
        % Otherwise, we will be unable to properly index and replace elements in 
        % smallFontPostJOL and largeFontPostJOL.
        if smallFontIndex == 7
            smallFontIndex = 1;
        end
        if largeFontIndex == 7
            largeFontIndex = 1;
        end        
    end
    
    %% ASK USER TO RECALL WORDS FROM PRIOR LIST
    Screen('Flip',window);
    % Use GetEchoString so user can see what they are typing while recalling words
    [string,terminatorChar] = GetEchoString(window,'Recall: ',10,cy,BLACK,WHITE,[],[],20,[]);
    recalledWords = userRecall(string);

    %% ACTUAL RECALL DATA
    for k = 1:length(recalledWords)
        if ~any(strcmp(list,recalledWords{k}))
            actualRecall2(i,k) = 0; % if a word was not recalled or recalled incorrectly 
        else
            indexList = strfind(list,recalledWords(k));
            index = find(not(cellfun('isempty',indexList)));
            actualRecall2(i,index) = 100;
            % categorize correct word by small or large font recall
            if fontConditions(i,index)==1
                smallFontRecall = smallFontRecall+100;
            elseif fontConditions(i,index)==2
                largeFontRecall = largeFontRecall+100;
            end
        end
    end

    %% ASK USER TO PRESS ANY KEY TO BEGIN NEXT LIST
    if i ~= nListsPerCondition
        Screen('Flip',window);
        DrawFormattedText(window, 'Press any key to begin the next list.','center','center',BLACK,[],[],[],1.5);
        Screen('Flip',window);
        WaitSecs(0.3+rand*0.3);
        startTime = GetSecs;      % getting computer time at this moment
        [secs, keyCode] = KbWait; % wait for keypress for participant to continue
        responseTime = secs - startTime; % recording response time
    end
    
end
endTime2 = GetSecs; % get end time after condition is complete
responseTime2 = endTime2 - startTime2; % calculate response time for condition


elseif conditionOrder(c) == 3 % run condition 3
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%% CONDITION 3 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% JOLs are made before each word and font size is constant %%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% INITIALIZING WORD LISTS, PREDICTED JOLS, AND ACTUAL RECALL %%
% Combine Lists 9-12 for Display
condition3Lists = [list9; list10; list11; list12];
% Initialize Predicted JOLs Vector for Condition 3
predictedJOLs3 = [0 0 0 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0 0 0 0 0;...
    0 0 0 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0 0 0 0 0];
% Initialize Actual Recall Vector
actualRecall3 = [0 0 0 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0 0 0 0 0;...
    0 0 0 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0 0 0 0 0];

%% INTRODUCING THE TASK/CONDITIONS
% Drawing Two Rectangles (one on top of other):
Screen('Flip',window);
rectangleRect = [cx-400 cy-250 cx+400 cy+250] ; % coordinates for top left and bottom right 
Screen('FillRect', window, ORANGE, rectangleRect); % draw filled rectangle
rectangleRect = [cx-300 cy-200 cx+300 cy+200] ; % coordinates for top left and bottom right 
Screen('FillRect', window, LIGHTBLUE, rectangleRect); % draw filled rectangle
% Drawing Instructions on top of the rectangles:
Screen('TextSize', window,20);; % Set font size back to 20
DrawFormattedText(window, condition3Instructions,'center','center',BLACK);
Screen('Flip',window);
WaitSecs(0.3+rand*0.3);
startTime = GetSecs;      % getting computer time at this moment
[secs, keyCode] = KbWait; % wait for keypress for participant to continue
responseTime = secs - startTime; % recording response time

%% DISPLAYING THE WORD LIST AND ASKING FOR JOL BEFORE EACH WORD %%
startTime3 = GetSecs; % get start time at beginning of condition
for i = 1:nListsPerCondition
    list = condition3Lists(i, :);       % clarify list of words
    
    for j = 1:listLength
        % GET JOL FOR WORD:
        Screen('TextSize', window,30);  
        DrawFormattedText(window, predictionJOL,'center','center',BLACK);
        number = str2double(GetEchoString(window, '',cx-10,cy+35,BLACK,WHITE,[],[],20,[]));
        Screen('Flip',window);
        predictedJOLs3(i,j) = number; % add JOL for word to predictedJOLs
        % DISPLAY WORD:
        word = list{j};                 % get each word of the list
        Screen('TextSize', window,40);  % set font size to 40
        DrawFormattedText(window, word,'center','center',BLACK);
        Screen('Flip',window);          % displaying the word for 2 secs
        WaitSecs(2);
        Screen('Flip',window);
    end
    
    %% ASK USER TO RECALL WORDS FROM PRIOR LIST
    Screen('Flip',window);
    Screen('TextSize', window,30);
    % Use GetEchoString so user can see what they are typing while recalling words
    [string,terminatorChar] = GetEchoString(window,'Recall: ',10,cy,BLACK,WHITE,[],[],20,[]);
    recalledWords = userRecall(string);

    %% ACTUAL RECALL DATA
    for k = 1:length(recalledWords)
        if ~any(strcmp(list,recalledWords{k}))
            actualRecall3(i,k) = 0; % if a word was not recalled or recalled incorrectly 
        else
            indexList = strfind(list,recalledWords(k));
            index = find(not(cellfun('isempty',indexList)));
            actualRecall3(i,index) = 100;
        end
    end

    %% ASK USER TO PRESS ANY KEY TO BEGIN NEXT LIST
    if i ~= nListsPerCondition
        Screen('Flip',window);
        DrawFormattedText(window, 'Press any key to begin the next list.','center','center',BLACK,[],[],[],1.5);
        Screen('Flip',window);
        WaitSecs(0.3+rand*0.3);
        startTime = GetSecs;      % getting computer time at this moment
        [secs, keyCode] = KbWait; % wait for keypress for participant to continue
        responseTime = secs - startTime; % recording response time
    end
end 
endTime3 = GetSecs; % get end time after condition is complete
responseTime3 = endTime3 - startTime3; % calculate response time for condition


elseif conditionOrder(c) == 4 % run condition 4
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%% CONDITION 4 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% JOLs are made before each word and font size is varied %%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% INITIALIZING WORD LISTS, PREDICTED JOLS, AND ACTUAL RECALL %%
% Combine Lists 13-16 for Display
condition4Lists = [list13; list14; list15; list16];
% Initialize Predicted JOLs Vector for Condition 4
predictedJOLs4 = [0 0 0 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0 0 0 0 0;...
    0 0 0 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0 0 0 0 0];
% Initialize Actual Recall Vector of Participant
actualRecall4 = [0 0 0 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0 0 0 0 0;...
    0 0 0 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0 0 0 0 0];
% Initialize smallFontIndex and largeFontIndex to record JOLs based on font
smallFontIndex = 1;
largeFontIndex = 1;

%% INTRODUCING THE TASK/CONDITIONS
% Drawing Two Rectangles (one on top of other):
Screen('Flip',window);
rectangleRect = [cx-400 cy-250 cx+400 cy+250] ; % coordinates for top left and bottom right 
Screen('FillRect', window, ORANGE, rectangleRect); % draw filled rectangle
rectangleRect = [cx-300 cy-200 cx+300 cy+200] ; % coordinates for top left and bottom right 
Screen('FillRect', window, LIGHTBLUE, rectangleRect); % draw filled rectangle
% Drawing Instructions on top of the rectangles:
Screen('TextSize', window,20);
DrawFormattedText(window, condition4Instructions,'center','center',BLACK);
Screen('Flip',window);
WaitSecs(0.3+rand*0.3);
startTime = GetSecs;      % getting computer time at this moment
[secs, keyCode] = KbWait; % wait for keypress for participant to continue
responseTime = secs - startTime; % recording response time

%% DISPLAYING THE WORD LIST AND ASKING FOR JOL AFTER EACH WORD %%
startTime4 = GetSecs; % get start time at beginning of condition
for i = 1:nListsPerCondition
    list = condition4Lists(i, :);       % clarify list of words
    
    for j = 1:listLength
        % GET JOL FOR WORD:
        Screen('TextSize', window,30);  
        DrawFormattedText(window, predictionJOL,'center','center',BLACK);
        number = str2double(GetEchoString(window, '',cx-10,cy+35,BLACK,WHITE,[],[],20,[]));
        Screen('Flip',window);
        predictedJOLs4(i,j) = number; % add JOL for word to predictedJOLs
        Screen('Flip',window);
        % SET FONT SIZE OF WORD:
        if fontConditions(i+4,j)==1
            Screen('TextSize', window,20); % set small font
        elseif fontConditions(i+4,j)==2
            Screen('TextSize', window,75); % set large font
        end
        % DISPLAY WORD:
        word = list{j};                 % get each word of the list
        DrawFormattedText(window, word,'center','center',BLACK);
        Screen('Flip',window);          % displaying the word for 2 secs
        WaitSecs(2);
        % RECORD JOL BASED ON FONT SIZE
        if fontConditions(i+4,j)==1
            smallFontPreJOL4(i,smallFontIndex) = number;
            smallFontIndex = smallFontIndex+1;
        elseif fontConditions(i+4,j)==2
            largeFontPreJOL4(i,largeFontIndex) = number;
            largeFontIndex = largeFontIndex+1;
        end
        % RESET FONT INDEX IF EQUAL TO 7
        % Otherwise, we will be unable to properly index and replace elements in 
        % smallFontPostJOL and largeFontPostJOL.
        if smallFontIndex == 7
            smallFontIndex = 1;
        end
        if largeFontIndex == 7
            largeFontIndex = 1;
        end        
    end
    %% ASK USER TO RECALL WORDS FROM PRIOR LIST
    Screen('Flip',window);
    Screen('TextSize', window,30);
    % Use GetEchoString so user can see what they are typing while recalling words
    [string,terminatorChar] = GetEchoString(window,'Recall: ',10,cy,BLACK,WHITE,[],[],20,[]);
    recalledWords = userRecall(string);

    %% ACTUAL RECALL DATA
    for k = 1:length(recalledWords)
        if ~any(strcmp(list,recalledWords{k}))
            actualRecall4(i,k) = 0; % if a word was not recalled or recalled incorrectly 
        else
            indexList = strfind(list,recalledWords(k));
            index = find(not(cellfun('isempty',indexList)));
            actualRecall4(i,index) = 100;
            
            % categorize correct word by small or large font recall
            if fontConditions(i+4,index)==1
                smallFontRecall = smallFontRecall+100;
            elseif fontConditions(i+4,index)==2
                largeFontRecall = largeFontRecall+100;
            end
        end
    end

    %% ASK USER TO PRESS ANY KEY TO BEGIN NEXT LIST
    if i ~= nListsPerCondition
        Screen('Flip',window);
        DrawFormattedText(window, 'Press any key to begin the next list.','center','center',BLACK,[],[],[],1.5);
        Screen('Flip',window);
        WaitSecs(0.3+rand*0.3);
        startTime = GetSecs;      % getting computer time at this moment
        [secs, keyCode] = KbWait; % wait for keypress for participant to continue
        responseTime = secs - startTime; % recording response time
    end 
end
endTime4 = GetSecs; % get end time after condition is complete
responseTime4 = endTime4 - startTime4; % calculate response time for condition


elseif conditionOrder(c) == 5 % run condition 5
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%% CONDITION 5 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% JOLs are made before each word, font size is constant, %%%%%%%%%%
%%%%%%%%         and position number is included                %%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% INITIALIZING WORD LISTS, PREDICTED JOLS, AND ACTUAL RECALL %%
% Combine Lists 17-20 for Display
condition5Lists = [serialList17; serialList18; serialList19; serialList20];
% Combine Lists 17-20 for word comparison (no serial numbers in words)
condition5ListsCompare = [list17; list18; list18; list20];
% Initialize Predicted JOLs Vector for Condition 5
predictedJOLs5 = [0 0 0 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0 0 0 0 0;...
    0 0 0 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0 0 0 0 0];
% Initialize Actual Recall Vector
actualRecall5 = [0 0 0 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0 0 0 0 0;...
    0 0 0 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0 0 0 0 0];

%% INTRODUCING THE TASK/CONDITIONS
% Drawing Two Rectangles (one on top of other):
Screen('Flip',window);
rectangleRect = [cx-400 cy-250 cx+400 cy+250] ; % coordinates for top left and bottom right 
Screen('FillRect', window, ORANGE, rectangleRect); % draw filled rectangle
rectangleRect = [cx-300 cy-200 cx+300 cy+200] ; % coordinates for top left and bottom right 
Screen('FillRect', window, LIGHTBLUE, rectangleRect); % draw filled rectangle
% Drawing Instructions on top of the rectangles:
Screen('TextSize', window,20); 
DrawFormattedText(window, condition5Instructions,'center','center',BLACK);
Screen('Flip',window);
WaitSecs(0.3+rand*0.3);
startTime = GetSecs;      % getting computer time at this moment
[secs, keyCode] = KbWait; % wait for keypress for participant to continue
responseTime = secs - startTime; % recording response time

startTime5 = GetSecs; % get start time at beginning of condition
%% DISPLAYING THE WORD LIST AND ASKING FOR JOL BEFORE EACH WORD %%
for i = 1:nListsPerCondition
    list = condition5Lists(i, :);               % clarify list of words
    listCompare = condition5ListsCompare (i,:); % word to compare user input to
    for j = 1:listLength
        % GET JOL FOR WORD:
        Screen('TextSize', window,30); 
        predSN = predictionSerialNumber{j}; % get prediction serial number
        DrawFormattedText(window,predSN,cx,cy-60,BLACK); % display above text
        DrawFormattedText(window, predictionJOL,'center','center',BLACK);
        number = str2double(GetEchoString(window, '',cx-35,cy+35,BLACK,WHITE,[],[],20,[]));
        Screen('Flip',window);
        predictedJOLs5(i,j) = number; % add JOL for word to predictedJOLs
        % DISPLAY WORD:
        word = list{j};                 % get each word of the list
        Screen('TextSize', window,40);  % set font size to 40
        DrawFormattedText(window, word,'center','center',BLACK);
        Screen('Flip',window);          % displaying the word for 2 secs
        WaitSecs(2);
        Screen('Flip',window);
    end
    
    %% ASK USER TO RECALL WORDS FROM PRIOR LIST
    Screen('Flip',window);
    Screen('TextSize', window,30);
    % Use GetEchoString so user can see what they are typing while recalling words
    [string,terminatorChar] = GetEchoString(window,'Recall: ',10,cy,BLACK,WHITE,[],[],20,[]);
    recalledWords = userRecall(string);

    %% ACTUAL RECALL DATA
    for k = 1:length(recalledWords)
        if ~any(strcmp(listCompare,recalledWords{k}))
            actualRecall5(i,k) = 0; % if a word was not recalled/recalled incorrectly 
        else
            indexList = strfind(listCompare,recalledWords(k));
            index = find(not(cellfun('isempty',indexList)));
            actualRecall5(i,index) = 100;
        end
    end

    %% ASK USER TO PRESS ANY KEY TO BEGIN NEXT LIST
    if i ~= nListsPerCondition
        Screen('Flip',window);
        DrawFormattedText(window, 'Press any key to begin the next list.','center','center',BLACK,[],[],[],1.5);
        Screen('Flip',window);
        WaitSecs(0.3+rand*0.3);
        startTime = GetSecs;      % getting computer time at this moment
        [secs, keyCode] = KbWait; % wait for keypress for participant to continue
        responseTime = secs - startTime; % recording response time
    end
end
endTime5 = GetSecs; % get end time after condition is complete
responseTime5 = endTime5 - startTime5; % calculate response time for condition


elseif conditionOrder(c) == 6 % run condition 6
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%% CONDITION 6 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%% JOLs are made before each word, font size is varied, %%%%%%%%%%%
%%%%%%%%%         and position number is included              %%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Combine Lists 21-24 for Display
condition6Lists = [serialList21; serialList22; serialList23; serialList24];
% Combine Lists 17-20 for word comparison (no serial numbers in words)
condition6ListsCompare = [list21; list22; list23; list24];
% Initialize Predicted JOLs Vector for Condition 6
predictedJOLs6 = [0 0 0 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0 0 0 0 0;...
    0 0 0 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0 0 0 0 0];
% Initialize Actual Recall Vector
actualRecall6 = [0 0 0 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0 0 0 0 0;...
    0 0 0 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0 0 0 0 0];
% Initialize smallFontIndex and largeFontIndex to record JOLs based on font
smallFontIndex = 1;
largeFontIndex = 1;

%% INTRODUCING THE TASK/CONDITIONS
% Drawing Two Rectangles (one on top of other):
Screen('Flip',window);
rectangleRect = [cx-400 cy-250 cx+400 cy+250] ; % coordinates for top left and bottom right 
Screen('FillRect', window, ORANGE, rectangleRect); % draw filled rectangle
rectangleRect = [cx-300 cy-200 cx+300 cy+200] ; % coordinates for top left and bottom right 
Screen('FillRect', window, LIGHTBLUE, rectangleRect); % draw filled rectangle
% Drawing Instructions on top of the rectangles:
Screen('TextSize', window,20); % Set font size back to 20
DrawFormattedText(window, condition6Instructions,'center','center',BLACK);
Screen('Flip',window);
WaitSecs(0.3+rand*0.3);
startTime = GetSecs;      % getting computer time at this moment
[secs, keyCode] = KbWait; % wait for keypress for participant to continue
responseTime = secs - startTime; % reco  rding response time

startTime6 = GetSecs; % get start time at beginning of condition
%% DISPLAYING THE WORD LIST AND ASKING FOR JOL AFTER EACH WORD %%
for i = 1:nListsPerCondition
    list = condition6Lists(i, :);       % index list of words for display
    listCompare = condition6ListsCompare (i,:); % list of words for comparison
    for j = 1:listLength
        % GET JOL FOR WORD:
        Screen('TextSize', window,30); 
        predSN = predictionSerialNumber{j}; % get prediction serial number
        DrawFormattedText(window,predSN,cx,cy-60,BLACK); % display above text
        DrawFormattedText(window, predictionJOL,'center','center',BLACK);
        number = str2double(GetEchoString(window, '',cx-10,cy+35,BLACK,WHITE,[],[],20,[]));
        Screen('Flip',window);
        predictedJOLs4(i,j) = number; % add JOL for word to predictedJOLs
        Screen('Flip',window);
        % SET FONT SIZE OF WORD:
        if fontConditions(i+8,j)==1
            Screen('TextSize', window,20); % set small font
        elseif fontConditions(i+8,j)==2
            Screen('TextSize', window,75); % set large font
        end
        % DISPLAY WORD:
        word = list{j};                 % get each word of the list
        DrawFormattedText(window, word,'center','center',BLACK);
        Screen('Flip',window);          % displaying the word for 2 secs
        WaitSecs(2);
        % RECORD JOL BASED ON FONT SIZE
        if fontConditions(i+8,j)==1
            largeFontPreJOL6(i,smallFontIndex) = number;
            smallFontIndex = smallFontIndex+1;
        elseif fontConditions(i+8,j)==2
            largeFontPreJOL6(i,largeFontIndex) = number;
            largeFontIndex = largeFontIndex+1;
        end
        % RESET FONT INDEX IF EQUAL TO 7
        % Otherwise, we will be unable to properly index and replace elements in 
        % smallFontPostJOL and largeFontPostJOL.
        if smallFontIndex == 7
            smallFontIndex = 1;
        end
        if largeFontIndex == 7
            largeFontIndex = 1;
        end        
    end
    
    %% ASK USER TO RECALL WORDS FROM PRIOR LIST
    Screen('Flip',window);
    Screen('TextSize', window,30);
    % Use GetEchoString so user can see what they are typing while recalling words
    [string,terminatorChar] = GetEchoString(window,'Recall: ',10,cy,BLACK,WHITE,[],[],20,[]);
    recalledWords = userRecall(string);

    %% ACTUAL RECALL DATA
    for k = 1:length(recalledWords)
        if ~any(strcmp(listCompare,recalledWords{k}))
            actualRecall6(i,k) = 0; % if a word was not recalled or recalled incorrectly 
        else
            indexList = strfind(listCompare,recalledWords(k));
            index = find(not(cellfun('isempty',indexList)));
            actualRecall6(i,index) = 100;
            
            % categorize correct word by small or large font recall
            if fontConditions(i+8,index)==1
                smallFontRecall = smallFontRecall+100;
            elseif fontConditions(i+8,index)==2
                largeFontRecall = largeFontRecall+100;
            end
        end
    end

    %% ASK USER TO PRESS ANY KEY TO BEGIN NEXT LIST
    if i ~= nListsPerCondition
        Screen('Flip',window);
        DrawFormattedText(window, 'Press any key to begin the next list.','center','center',BLACK,[],[],[],1.5);
        Screen('Flip',window);
        WaitSecs(0.3+rand*0.3);
        startTime = GetSecs;      % getting computer time at this moment
        [secs, keyCode] = KbWait; % wait for keypress for participant to continue
        responseTime = secs - startTime; % recording response time
    end    
end
endTime6 = GetSecs; % get end time after condition is complete
responseTime6 = endTime6 - startTime6; % calculate response time for condition
    
%% CONCLUSION OF THE EXPERIMENT %%
elseif conditionOrder(c) == 7
    % Display Logo Again and Play Sound
    Screen('Flip',window);
    Screen('DrawTexture',window,logoTex);
    DrawFormattedText(window,'Thank you for participating! Press your ''escape'' key to exit.',...
        'center',[],BLACK,[],[],[],1.5);
    Screen('Flip',window); 
    PsychPortAudio('FillBuffer', audioPort, boing);
    PsychPortAudio('Start', audioPort);   % play boing audio
    PsychPortAudio('Stop', audioPort, 1); % stop when finished
    WaitSecs(3);   
    exitNow = true;
end
    
    % If the participant presses "esc", they can leave the experiment.
    [secs, keyCode] = KbPressWait;
    keyPressed = KbName(keyCode);
    if strcmpi(keyPressed,'escape')
        exitNow = true;
    end
    if exitNow
        break;  % get out of the while loop
    end
  end 
end 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                          %% RECORD RESULTS %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%% CONDITION ONE RESULTS %%%%%%%%%%%%%%%%%%%%%%%%%%%
% Average Recall of Condition 1
Results.averageRecall1 = mean(actualRecall1);
% Predicted JOLs on Each Trial
Results.C1JOL1 = predictedJOLs1(1,:); Results.C1JOL2 = predictedJOLs1(2,:);
Results.C1JOL3 = predictedJOLs1(3,:); Results.C1JOL4 = predictedJOLs1(4,:);
%%%%%%%%%%%%%%%%%%%%%%%% CONDITION TWO RESULTS %%%%%%%%%%%%%%%%%%%%%%%%%%%
% Average Recall of Condition 2
Results.averageRecall2 = mean(actualRecall2);
% Predicted JOLs on Each Trial
Results.C2JOL1 = predictedJOLs2(1,:); Results.C2JOL2 = predictedJOLs2(2,:);
Results.C2JOL3 = predictedJOLs2(3,:); Results.C2JOL4 = predictedJOLs2(4,:);
%%%%%%%%%%%%%%%%%%%%%%% CONDITION THREE RESULTS %%%%%%%%%%%%%%%%%%%%%%%%%%
% Average Recall of Condition 3
Results.averageRecall3 = mean(actualRecall3);
% Predicted JOLs on Each Trial
Results.C3JOL1 = predictedJOLs3(1,:); Results.C3JOL2 = predictedJOLs3(2,:);
Results.C3JOL3 = predictedJOLs3(3,:); Results.C3JOL4 = predictedJOLs3(4,:);
%%%%%%%%%%%%%%%%%%%%%%% CONDITION FOUR RESULTS %%%%%%%%%%%%%%%%%%%%%%%%%%%
% Average Recall of Condition 4
Results.averageRecall4 = mean(actualRecall4);
% Predicted JOLs on Each Trial
Results.C4JOL1 = predictedJOLs4(1,:); Results.C4JOL2 = predictedJOLs4(2,:);
Results.C4JOL3 = predictedJOLs4(3,:); Results.C4JOL4 = predictedJOLs4(4,:);
%%%%%%%%%%%%%%%%%%%%%%%% CONDITION FIVE RESULTS %%%%%%%%%%%%%%%%%%%%%%%%%%
% Average Recall of Condition 5
Results.averageRecall5 = mean(actualRecall5);
% Predicted JOLs on Each Trial
Results.C5JOL1 = predictedJOLs5(1,:); Results.C5JOL2 = predictedJOLs5(2,:);
Results.C5JOL3 = predictedJOLs5(3,:); Results.C5JOL4 = predictedJOLs5(4,:);
%%%%%%%%%%%%%%%%%%%%%%%% CONDITION SIX RESULTS %%%%%%%%%%%%%%%%%%%%%%%%%%%
% Average Recall of Condition 6
Results.averageRecall6 = mean(actualRecall6);
% Predicted JOLs on Each Trial
Results.C6JOL1 = predictedJOLs6(1,:); Results.C6JOL2 = predictedJOLs6(2,:);
Results.C6JOL3 = predictedJOLs6(3,:); Results.C6JOL4 = predictedJOLs6(4,:);

%%%%%%%%%%%%%%%%% COMPARING JOLS FOR VARIED FONT SIZES %%%%%%%%%%%%%%%%%%%%
% Post-JOLs with Varied Font Size
Results.smallFontPostJOL = mean(mean(smallFontPostJOL)); % average post-JOL for small font
Results.largeFontPostJOL = mean(mean(largeFontPostJOL)); % average post-JOL for large font
% Pre-JOLs with Varied Font Size
smallFontPreJOL = [smallFontPreJOL4; smallFontPreJOL6]; % combine condition 4 and 6
Results.smallFontPreJOL = mean(mean(smallFontPreJOL));  % average pre-JOL for small font
largeFontPreJOL = [largeFontPreJOL4; largeFontPreJOL6]; % combine condition 4 and 6
Results.largeFontPreJOL = mean(mean(largeFontPreJOL));  % average pre-JOL for large font

%%%%%%%%%%%%%%%%% AVERAGE JOLS BASED ON FONT VARIATION %%%%%%%%%%%%%%%%%%%%
% Average JOL based on Font Size
Results.averageSameFontJOL = mean(mean([predictedJOLs1; predictedJOLs3; predictedJOLs5]));
Results.averageLargeFontJOL = mean(mean(largeFontPostJOL)); % avg JOL when subjects KNEW large size
Results.averageSmallFontJOL = mean(mean(smallFontPostJOL)); % avg JOL when subjects KNEW small size
% Actual Recall based on Font Size
Results.averageSameFontRecall = mean(mean([actualRecall1; actualRecall3; actualRecall5]));
Results.averageLargeFontRecall = (largeFontRecall/72);
Results.averageSmallFontRecall = (smallFontRecall/72);
% Divide largeFontRecall and smallFontRecall by 72 to get percentage of
% small words and large words recalled.

%%%%%%%%%%%%%%%% SAVING RESPONSE TIMES TO RESULTS STRUCT %%%%%%%%%%%%%%%%%%
Results.responseTime1 = responseTime1;
Results.responseTime2 = responseTime2;
Results.responseTime3 = responseTime3;
Results.responseTime4 = responseTime4;
Results.responseTime5 = responseTime5;
Results.responseTime6 = responseTime6;

%%%%%%%%%%%%%%%%%%%%%% SAVING RESULTS TO .MAT FILE %%%%%%%%%%%%%%%%%%%%%%%%
savename = ['myData_' Results.SubjectID '.mat'];
save(savename,'Results');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CLEANUP %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PsychPortAudio('Close', audioPort);
Screen('Close',window);
catch
    sca; % screen close all
    psychrethrow(psychlasterror); % tells matlab to give report about any errors
end