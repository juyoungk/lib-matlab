function myfig

figureSize = get(gcf,'Position');

uicontrol('Style','text',...
          'String','My title',...
          'Position',[(figureSize(3)-100)/2 figureSize(4)+25 100 25],...
          'BackgroundColor',get(gcf,'Color'));

end