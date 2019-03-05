
// TO-DO:
//  * Use the name in the JSON to put a title on the top of the page,
//    followed by a horizontal separator.
//  * Create a disclosure menu item in that same title zone that reveals a
//    div containing an options form, empty at the start.
//  * Store at the top level of the semigroup's JSON a setting of whether
//    we are showing the sizes of H-classes (yes, no, or only when there
//    are hidden elements).  Initialize this to the third setting and
//    respect it in renderHClass().
//  * Create options controls for H-classes that let you choose which of
//    these options you want.  Every time they change, update the JSON and
//    re-render.
//  * Store in each D-class the number of elements that each of its
//    H-classes should display.  Initialize this value to something small,
//    such as 5.  Respect it in renderHClass().
//  * Add to the settings div some controls for popping up a dialog in
//    which you can enter the number and check a box for whether you're
//    changing it for just one D-class or all D-classes.
//    Upon any change, update the JSON and re-render.
//  * Make each H-class clickable, with a mouse cursor that is a hand, to
//    toggle between "...n more elements" mode and a version with all the
//    details available in the JSON.
//    (Whenever you create an H-class td, create two divs inside, one with
//    class 'default-view' and one with class 'expanded-view'.  Give the
//    parent td the class 'view-container'.  After putting the diagram in
//    the DOM, find all things in the document with class 'default-view'
//    and give them a click event that does this:  Find the nearest ances-
//    tor with class 'view-container' and then within that ancestor,
//    recursively search downward for each thing with class 'default-view'
//    or 'expanded-view' and toggle its visibility; do not recur inside.
//    Also, do not recur inside other 'view-container's.)
//  * Make the hover text for a row's "...n more" cell show the represent-
//    atives for all the hidden H-classes.
//  * Make "...n more H-classes" a link that expands all rows of the table
//    to show them.  Do this by making that td the 'default-view' class
//    in its tr, but make there be several other tds that show all the
//    missing pieces, and have class 'expanded-view'.  The row is the
//    'view-container' in this case.
//  * Make the hover text for a table's "...n more" row show the represent-
//    atives for all the H-classes in all the hidden rows.
//  * Make "...n more R-classes" a link that expands the table to show
//    more rows.  Do this by making that tr the 'default-view' class
//    in its table, but make there be several other trs that show all the
//    missing pieces, and have class 'expanded-view'.  The table is the
//    'view-container' in this case.
//  * Make the hover text for a diagrams's "...n more" row show a represent-
//    atives for each of the D-classes in all the hidden rows.
//  * Make "...n more D-classes" a link that expands the table to show
//    more rows.  Do this by making that tr the 'default-view' class
//    in its table, but make there be several other trs that show all the
//    missing pieces, and have class 'expanded-view'.  The table is the
//    'view-container' in this case.  Note that there will therefore be
//    some empty columns on the right hand side of the table when it's in
//    collapsed view, so that all rows can have the same width, and this is
//    not going to hurt anything.

// This visualization tool draws egg-box diagrams for semigroups, if
// passed the appropriate data in JSON form.
//
// The JSON data should have the following attributes:
// ( DOCUMENTATION TO-DO )

window.requirejs.config( {
    paths : {
        dialog : 'https://cdnjs.cloudflare.com/ajax/libs/dialog-polyfill/0.4.10/dialog-polyfill.min',
    }
} );

function goodAlert ( html ) {
    var dialog = document.createElement( 'dialog' );
    var button = document.createElement( 'a' );
    button.href = '#';
    button.textContent = String.fromCharCode( 10006 );
    button.style.position = 'absolute';
    button.style.right = '5px';
    button.style.top = '5px';
    button.style.textDecoration = 'none';
    button.style.color = '#000';
    button.addEventListener( 'click', function ( event ) {
        dialog.close();
    } );
    dialog.appendChild( button );
    var div = document.createElement( 'div' );
    div.innerHTML = html;
    dialog.appendChild( div );
    document.body.appendChild( dialog );
    dialog.showModal();
    document.activeElement.blur();
}

function more ( num, type ) {
    return `...${num} more ${type}${num==1?'':/s$/.test(type)?'es':'s'}`;
}

function elt ( html, tag, attrs ) {
    if ( typeof( tag ) == 'undefined' ) tag = 'p';
    var result = document.createElement( tag );
    if ( attrs )
        for ( var key in attrs )
            if ( attrs.hasOwnProperty( key ) )
                result.setAttribute( key, attrs[key] );
    if ( html ) result.innerHTML = html;
    return result;
}

function getLimit ( obj, options ) {
    if ( obj.hasOwnProperty( 'DClasses' ) ) {
        var limit = options.DLimit;
        var count = obj.DClasses.length;
    } else if ( obj.hasOwnProperty( 'RClasses' ) ) {
        var limit = options.RLimit;
        var count = obj.RClasses.length;
    } else if ( obj.hasOwnProperty( 'HClasses' ) ) {
        var limit = options.LLimit;
        var count = obj.HClasses.length;
    } else if ( obj.hasOwnProperty( 'elements' ) ) {
        var limit = options.HLimit;
        var count = obj.elements.length;
    } else {
        throw obj;
    }
    return limit > 0 ? Math.min( limit, count ) : count;
}

function renderHClass ( hclass, options ) {
    // create both expanded and default views, between which
    // the user can toggle
    const expandedView = elt( null, 'div' );
    const defaultView = elt( null, 'div' );
    // put a size heading in the expanded view, and copy it to
    // the default view if and only if the options say to do so
    const heading = elt( hclass.size == 1 ?
        '1 element:' : `${hclass.size} elements:` );
    expandedView.appendChild( heading );
    if ( options.HSize )
        defaultView.appendChild( heading.cloneNode( true ) );
    // put all element names into the expanded view, then a
    // subset of them into the default view
    expandedView.appendChild(
        elt( hclass.elements.join( '<br>' ) ) );
    const numToShow = getLimit( hclass, options );
    var eltsToShow = hclass.elements.slice( 0, numToShow );
    if ( numToShow < hclass.size )
        eltsToShow.push( options.HSize ? '...'
            : more( hclass.size - numToShow, 'element' ) );
    defaultView.appendChild(
        elt( eltsToShow.join( '<br>' ) ) );
    // make the default view show expanded info on hover, but
    // make the expanded view say you can click to shrink
    expandedView.setAttribute( 'title', 'Click to collapse' );
    var hoverText = hclass.size > 1 ?
        `All ${hclass.size} elements:\n` : 'One element:<br>';
    hoverText += hclass.elements.join( '\n' );
    defaultView.setAttribute( 'title', hoverText );
    // put both views into the result, but hide one
    var result = elt( null, 'td' );
    result.appendChild( defaultView );
    result.appendChild( expandedView );
    expandedView.style.display = 'none';
    return result;
}

function renderRClass ( rclass, options ) {
    var result = elt( null, 'tr' );
    const numToShow = getLimit( rclass, options );
    for ( var i = 0 ; i < numToShow ; i++ )
        result.appendChild( renderHClass( rclass.HClasses[i], options ) );
    if ( numToShow < rclass.size )
        result.appendChild( elt( more( rclass.size - numToShow, 'H-class' ),
            'td' ) );
    return result;
}

function renderDClass ( dclass, options ) {
    var result = elt( null, 'table',
        { border : 1, cellspacing : 0, cellpadding : 5 } );
    const numToShow = getLimit( dclass, options );
    for ( var i = 0 ; i < numToShow ; i++ )
        result.appendChild( renderRClass( dclass.RClasses[i], options ) );
    if ( numToShow < dclass.size ) {
        const row = elt( null, 'tr' );
        var rowLength = getLimit( dclass.RClasses[0], options );
        if ( rowLength < dclass.RClasses[0].size ) rowLength++;
        row.appendChild( elt( more( dclass.size - numToShow, 'R-class' ),
            'td', { colspan : rowLength } ) );
        result.appendChild( row );
    }
    return result;
}

function oneHotTableRow ( content, index, length ) {
    var result = elt( null, 'tr' );
    var cell = elt( null, 'td' );
    cell.appendChild( content );
    for ( var i = 0 ; i < length ; i++ )
        result.appendChild( i == index ? cell : elt( null, 'td' ) );
    return result;
}

function renderEggBoxDiagram ( diagram ) {
    var result = elt( null, 'table', { border : 0 } );
    const numToShow = getLimit( diagram, diagram.options );
    const tableSize = numToShow + ( numToShow < diagram.size ? 1 : 0 );
    for ( var i = 0 ; i < numToShow ; i++ )
        result.appendChild( oneHotTableRow(
            renderDClass( diagram.DClasses[i], diagram.options ),
            i, tableSize ) );
    if ( numToShow < tableSize )
        result.appendChild( oneHotTableRow(
            elt( more( diagram.size - numToShow, 'D-class' ), 'td' ),
            numToShow, tableSize ) );
    const wrapper = elt( null, 'div' );
    wrapper.innerHTML =
        '<style scoped>'
      + '@import url( "https://bootswatch.com/4/yeti/bootstrap.min.css" );'
      + '</style>';
    wrapper.appendChild( result );
    return wrapper;
}

window.VisualizationTools['egg-box'] =
function ( element, json, callback ) {
    // var tmp = document.createElement( 'pre' );
    // tmp.textContent = JSON.stringify( JSON.parse( json.data ), null, 4 );
    // tmp.setAttribute( 'title', 'foo' );
    // tmp.addEventListener( 'click', function ( event ) {
    //     goodAlert( '<p><b>HELLO!</b></p>' );
    // } );
    // element.appendChild( tmp );
    // callback( element, tmp );
    const diagram = renderEggBoxDiagram( JSON.parse( json.data ) );
    element.appendChild( diagram );
    callback( element, diagram );
};
