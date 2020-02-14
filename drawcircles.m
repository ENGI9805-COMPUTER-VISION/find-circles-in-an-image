function drawcircles(centers,radii)
    for n = 1:size(centers,1)
        circle(centers(n, 1), centers(n, 2), radii(n))
    end
end


function circle(x,y,r)

hold on
th = 0:pi/50:2*pi;
xunit = r * cos(th) + x;
yunit = r * sin(th) + y;
plot(xunit, yunit,'Color','r','LineWidth',3);
hold off

end