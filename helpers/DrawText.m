function [] = DrawText(window,Text,Colors,LeftAlign,TopAlign, Mirror, MirrorV)
% function [] = DrawText(window,Text,Colors,LeftAlign,TopAlign, Mirror)
%
%
%
Spacing     = 1.5;
TextSize    = Screen('TextSize',window);
ScreenRes	= Screen('Rect', window);

if size(Text,1) == 0
    Text = {'Test Text';'Test Text';'Test Text';'Test Text';'Test Text';'Test Text';'Test Text';'Test Text';};
end

% if ~iscell(Colors)
%    Colors = {Colors};
% end
    
if max(size(Colors)) == 0
    Colors = cell(size(Text,1),1);
    for i = 1:max(size(Text))
        Colors{i} = [1 1 1];
    end
elseif  max(size(Colors)) == 1
    tmpColors = Colors{1};
    Colors = cell(size(Text,1),1);
    for i = 1:max(size(Text))
        Colors{i} = tmpColors;
    end
end 

if size(LeftAlign,1) == 0
%     LeftAlign = ScreenRes(3)*0.45;
end

if size(TopAlign,1) == 0 & strcmp(TopAlign,'center')~=1
    TopAlign = ScreenRes(4)*0.5-0.5*size(Text,1)*TextSize*Spacing;
end

      
switch nargin,
    case 0
        error('Give up at least a windowptr');
    case 1
        Text = {'Test Text';'Test Text';'Test Text';'Test Text';'Test Text';'Test Text';'Test Text';'Test Text';};
        Colors = {[1 1 1]; [1 0 0]; [0 1 0]; [0 0 1]; [1 1 0]; [0 1 1]; [1 0 1]; [0 0 0];};
        LeftAlign = ScreenRes(3)*0.45;
        TopAlign = ScreenRes(4)*0.5-0.5*size(Text,1)*TextSize*Spacing;
        Mirror = 0;
        MirrorV = 0;
    case 2
        Colors = cell(size(Text,1),1);
        for i = 1:size(Text,1)
            Colors{i} = [1 1 1];
        end
        LeftAlign = ScreenRes(3)*0.45;
        TopAlign = ScreenRes(4)*0.5-0.5*size(Text,1)*TextSize*Spacing;
        Mirror = 0;
        MirrorV = 0;
    case 3
        LeftAlign = ScreenRes(3)*0.45;
        TopAlign = ScreenRes(4)*0.5-0.5*size(Text,1)*TextSize*Spacing;
        Mirror = 0;
        MirrorV = 0;
    case 4
        TopAlign = ScreenRes(4)*0.5-0.5*size(Text,1)*TextSize*Spacing;
        Mirror = 0;
        MirrorV = 0;
    case 5
        Mirror = 0;
        MirrorV = 0;
    case 6
        MirrorV = 0;
end


for i = 1:max(size(Text))
    
    DrawFormattedText(window, Text{i}, LeftAlign, TopAlign, Colors{i},[],Mirror,MirrorV);
%     Screen('DrawText', window, Text{i}, LeftAlign, TopAlign, Colors{i});
    
    if strcmp(TopAlign,'center')~=1
        TopAlign = TopAlign + Spacing*TextSize;
    end
end