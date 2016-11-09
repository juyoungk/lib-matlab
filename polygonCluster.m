function in = polygonCluster(X, Y, varargin)
%
% polygonCluster(X, Y)
% polygonCluster(X, Y, ax_draw, ax_plot)
%
% X, Y: different variables for a set of observations (usually 2-D images)
% 1. reshape X & Y into 1-D
%
% output in : 1-D true/false logical array (why not 2-D?)
% 

nVarargs = numel(varargin);
if nVarargs == 1
    ax_draw = varargin{1};
    ax_plot = varargin{1};
elseif nVarargs == 2
    ax_draw = varargin{1};
    ax_plot = varargin{2};
else
    ax_draw = gca; 
    ax_plot = gca;
end
hold(ax_draw, 'on');
hold(ax_plot, 'on');
axes(ax_draw);

X = reshape(X, [], 1);
Y = reshape(Y, [], 1);

% scatter plot
% figure; 
% plot(X, Y, 'kd','MarkerSize',3,'LineWidth',2);

% Draw for data selection
[xv, yv] = getPolygon;
in = inpolygon(X, Y, xv, yv);
%
plot(ax_draw, xv, yv, 'bs-', 'MarkerSize',5,'LineWidth',2);
plot(ax_draw, X(in), Y(in), 'ro', 'MarkerSize',1.5,'LineWidth',2);
% Plot axis
plot(ax_plot, xv, yv, 'bs-', 'MarkerSize',5,'LineWidth',2);
plot(ax_plot, X(in), Y(in), 'ro', 'MarkerSize',1.5,'LineWidth',2);

end