
// This visualization tool draws egg-box diagrams for semigroups, if
// passed the appropriate data in JSON form.
//
// The JSON data should have the following attributes:
// ( DOCUMENTATION TO-DO )

window.requirejs.config( {
    paths : {
        dialog : 'https://cdnjs.cloudflare.com/ajax/libs/dialog-polyfill/0.4.10/dialog-polyfill.min'
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

function getLimit ( obj ) {
    const options = obj.options || obj.semigroup.options;
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

function renderHClass ( hclass ) {
    const options = hclass.semigroup.options;
    // create both expanded and default views, between which
    // the user can toggle
    const expandedView = elt( null, 'div' );
    const defaultView = elt( null, 'div' );
    // put a size heading in the expanded view, and copy it to
    // the default view if and only if the options say to do so
    const heading = elt( hclass.size == 1 ?
        '1 element:' : `${hclass.size} elements:` );
    expandedView.appendChild( heading );
    const numToShow = getLimit( hclass );
    const showHSize = options.showHClassSizes == 'yes'
      || ( options.showHClassSizes == 'if-hidden-elements'
        && numToShow < hclass.size );
    if ( showHSize )
        defaultView.appendChild( heading.cloneNode( true ) );
    // put all element names into the expanded view, then a
    // subset of them into the default view
    expandedView.appendChild(
        elt( '<nobr>' + hclass.elements.join( '</nobr><br><nobr>' )
           + '</nobr>' ) );
    var eltsToShow = hclass.elements.slice( 0, numToShow );
    if ( numToShow < hclass.size )
        eltsToShow.push( showHSize ? '&vellip;'
            : more( hclass.size - numToShow, 'elements' ) );
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

function renderRClass ( rclass ) {
    const options = rclass.semigroup.options;
    var result = elt( null, 'tr', { class : 'table-active' } );
    const numToShow = getLimit( rclass );
    for ( var i = 0 ; i < numToShow ; i++ )
        result.appendChild( renderHClass( rclass.HClasses[i], options ) );
    if ( numToShow < rclass.size )
        result.appendChild( elt( more( rclass.size - numToShow, 'H-class' ),
            'td' ) );
    return result;
}

function renderDClass ( dclass ) {
    const options = dclass.semigroup.options;
    var result = elt( null, 'table', { class : 'd-class table-bordered' } );
    const numToShow = getLimit( dclass );
    for ( var i = 0 ; i < numToShow ; i++ )
        result.appendChild( renderRClass( dclass.RClasses[i], options ) );
    if ( numToShow < dclass.size ) {
        const row = elt( null, 'tr' );
        var rowLength = getLimit( dclass.RClasses[0] );
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

function diagramControlsDiv () {
    const result = elt( null, 'div', {
        class : 'card border-primary',
        style : 'margin: 1em;'
    } );
    result.appendChild( elt( 'Diagram settings', 'div', { class : 'card-header' } ) );
    const body = elt( null, 'div', { class : 'card-body' } );
    body.appendChild( elt( 'Section heading here', 'h4', { class : 'card-title' } ) );
    body.appendChild( elt( 'Section content here...', 'p', { class : 'card-text' } ) );
    body.appendChild( elt( 'Section heading here', 'h4', { class : 'card-title' } ) );
    body.appendChild( elt( 'Section content here...', 'p', { class : 'card-text' } ) );
    body.appendChild( elt( 'Section heading here', 'h4', { class : 'card-title' } ) );
    body.appendChild( elt( 'Section content here...', 'p', { class : 'card-text' } ) );
    result.appendChild( body );
    return result;
}

function renderEggBoxDiagram ( diagram ) {
    var result = elt( null, 'table', { border : 0 } );
    const numToShow = getLimit( diagram );
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
      + '@import url( "https://use.fontawesome.com/releases/v5.7.2/css/all.css" );\n'
      + '.d-class td {\n'
      + '  border: 2px solid #999;\n'
      + '  padding: 0.5em 1em 0.5em 1em;\n'
      + '}\n'
      + '</style>';
    wrapper.appendChild( elt( `Egg-box Diagram for "${diagram.name}"`, 'h2' ) );
    const exposer = elt( '<i class="fas fa-cog"></i>', 'button', {
        class : 'btn btn-primary',
        type : 'button',
        style : 'position: absolute; top: 0.5em; right: 0.5em'
    } );
    const controls = diagramControlsDiv();
    controls.style.display = 'none'
    exposer.addEventListener( 'click', function ( event ) {
        if ( controls.style.display == 'none' ) {
            controls.style.display = 'block';
        } else {
            controls.style.display = 'none';
        }
    } );
    wrapper.appendChild( exposer );
    wrapper.appendChild( controls );
    wrapper.appendChild( result );
    wrapper.style.margin = '1em';
    return wrapper;
}

function initializeSemigroup ( semigroup ) {
    // first setting must be one of:
    //   'yes' - always show sizes of H-classes
    //   'no' - never show them
    //   'if-hidden-elements' - show them iff there are too many
    // elements to display, so some are hidden behind an ellipsis
    semigroup.options.showHClassSizes = 'if-hidden-elements';
    semigroup.options.HLimit = 2;
    // add pointers from each subobject to the whole semigroup
    // data structure, for convenience
    for ( var i = 0 ; i < semigroup.DClasses.length ; i++ ) {
        const dclass = semigroup.DClasses[i];
        dclass.semigroup = semigroup;
        for ( var j = 0 ; j < dclass.RClasses.length ; j++ ) {
            const rclass = dclass.RClasses[j];
            rclass.DClass = dclass;
            rclass.semigroup = semigroup;
            for ( var k = 0 ; k < rclass.HClasses.length ; k++ ) {
                const hclass = rclass.HClasses[k];
                hclass.RClass = rclass;
                hclass.DClass = dclass;
                hclass.semigroup = semigroup;
            }
        }
    }
    return semigroup;
}

window.VisualizationTools['egg-box'] =
function ( element, json, callback ) {
    const diagram = renderEggBoxDiagram( initializeSemigroup(
        JSON.parse( json.data ) ) );
    element.appendChild( diagram );
    callback( element, diagram );
};
