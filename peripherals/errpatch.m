function p = errpatch(x,y,err,FC,FA)

p = patch([x,fliplr(x)],[y+err,fliplr(y-err)],'g');
p.FaceColor = FC;
p.FaceAlpha = FA;
p.LineStyle = 'none';

end