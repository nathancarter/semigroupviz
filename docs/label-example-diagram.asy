
settings.tex = "pdflatex";

label( shift( (99,-51) ) *
       graphic( "example-diagram.png", "width=200px" ) );

layer();

pen thick = linewidth( 1 );

void say ( pair topleft, pair botright, pen color,
           pair labelpt, string labeltext )
{
    pair center = ( topleft + botright ) / 2;
    path rect = box( topleft, botright );
    pair edge = intersectionpoints( rect, center--labelpt )[0];
    pair ldir = unit( labelpt - center );
    draw( rect, color + thick );
    draw( edge -- labelpt, color + thick );
    label( labeltext, labelpt, ldir, color );
}

pair cellsize = (33,27);
pair corner ( int cellx, int celly, int ofsx, int ofsy )
{
    return (cellx*cellsize.x+ofsx,-celly*cellsize.y-ofsy);
}
int labelcount = 0;
pair nextlabel ()
{
    pair result = (130,-20*labelcount);
    ++labelcount;
    return result;
}

say( corner(0,0,-2,-2), corner(1,1,2,2),
     heavygreen, nextlabel(), "$H$-class" );
say( corner(0,0,-4,-4), corner(1,3,4,2),
     blue, nextlabel(), "$L$-class" );
say( corner(0,0,-6,-6), corner(3,1,2,4),
     red, nextlabel(), "$R$-class" );
say( corner(0,0,-8,-8), corner(3,3,4,4),
     black, nextlabel(), "$D$-class" );

