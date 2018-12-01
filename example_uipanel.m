%% Create first figure
hf_sub(1) = figure(1);
hp(1) = uipanel('Parent',hf_sub(1),'Position',[0 0 1 1]);
subplot(2,2,1,'Parent',hp(1));
plot(1:10);
subplot(2,2,2,'Parent',hp(1));
surf(peaks);
subplot(2,2,3,'Parent',hp(1));
membrane;
subplot(2,2,4,'Parent',hp(1));
plot(rand(1,100));

%% Create second figure
hf_sub(2) = figure(2);
hp(2) = uipanel('Parent',hf_sub(2),'Position',[0 0 1 1]);
subplot(2,2,1,'Parent',hp(2));
histogram(randn(1,1000));
subplot(2,2,2,'Parent',hp(2));
membrane
subplot(2,2,3,'Parent',hp(2));
surf(peaks)
subplot(2,2,4,'Parent',hp(2));
plot(-(1:10));

%% Create combined figure
hf_main = figure(3);
npanels = numel(hp);
hp_sub = nan(1,npanels);
% Copy over the panels
for idx = 1:npanels
    hp_sub(idx) = copyobj(hp(idx),hf_main);
    set(hp_sub(idx),'Position',[(idx-1)/npanels,0,1/npanels,1]);
end