
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
        elt( '<nobr>' + hclass.elements.join( '</nobr><br><nobr>' )
           + '</nobr>' ) );
    const numToShow = getLimit( hclass, options );
    var eltsToShow = hclass.elements.slice( 0, numToShow );
    if ( numToShow < hclass.size )
        eltsToShow.push( options.HSize ? '...'
            : more( hclass.size - numToShow, 'element' ) );
    defaultView.appendChild(
        elt( '<nobr>' + eltsToShow.join( '</nobr><br><nobr>' )
           + '</nobr>' ) );
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
    var result = elt( null, 'tr', { class : 'table-active' } );
    const numToShow = getLimit( rclass, options );
    for ( var i = 0 ; i < numToShow ; i++ )
        result.appendChild( renderHClass( rclass.HClasses[i], options ) );
    if ( numToShow < rclass.size )
        result.appendChild( elt( more( rclass.size - numToShow, 'H-class' ),
            'td' ) );
    return result;
}

function renderDClass ( dclass, options ) {
    var result = elt( null, 'table', { class : 'd-class table-bordered' } );
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
        '<style scoped>\n'
      + '@import url( "https://bootswatch.com/4/yeti/bootstrap.min.css" );\n'
      + '.d-class td {\n'
      + '  border: 2px solid #999;\n'
      + '  padding: 0.5em 1em 0.5em 1em;\n'
      + '}\n'
      + '</style>';
    wrapper.appendChild( elt( `Egg-box Diagram for "${diagram.name}"`, 'h2' ) );
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
