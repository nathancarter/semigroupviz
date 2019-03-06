
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

function elt ( html, tag, attrs, children ) {
    if ( typeof( tag ) == 'undefined' ) tag = 'p';
    var result = document.createElement( tag );
    if ( attrs )
        for ( var key in attrs )
            if ( attrs.hasOwnProperty( key ) )
                result.setAttribute( key, attrs[key] );
    if ( html ) result.innerHTML = html;
    if ( children ) {
        if ( !( children instanceof Array ) )
            children = [ children ];
        children.map( c => result.appendChild( c ) );
    }
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
    const numToShow = hclass.DClass.numHClassElementsToShow;
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
    var result = elt( null, 'td', null,
        [ defaultView, expandedView ] );
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
        var rowLength = getLimit( dclass.RClasses[0] );
        if ( rowLength < dclass.RClasses[0].size ) rowLength++;
        result.appendChild( elt( null, 'tr', null,
            elt( more( dclass.size - numToShow, 'R-class' ),
                'td', { colspan : rowLength } ) ) );
    }
    return result;
}

function oneHotTableRow ( content, index, length ) {
    var result = elt( null, 'tr' );
    var cell = elt( null, 'td', null, content );
    for ( var i = 0 ; i < length ; i++ )
        result.appendChild( i == index ? cell : elt( null, 'td' ) );
    return result;
}

const radioButton = ( text, value, category, checked, id, cb ) => {
    const result = elt( text, 'div', { class : 'form-check' } );
    const label = elt( null, 'input', {
        type : 'radio',
        class : 'form-check-input',
        name : category,
        value : value
    } );
    if ( id ) label.setAttribute( 'id', id );
    if ( checked ) label.setAttribute( 'checked', true );
    result.insertBefore( label, result.childNodes[0] );
    label.addEventListener( 'change', cb );
    return result;
}
const getRadioGroupValue = ( category ) => {
    const theOne = Array.prototype.slice.apply(
        document.getElementsByTagName( 'input' )
    ).find( button =>
        button.getAttribute( 'type' ) == 'radio'
     && button.getAttribute( 'name' ) == category
     && button.checked );
    return theOne ? theOne.getAttribute( 'value' ) : undefined;
}

function diagramControlsDiv () {
    // make big settings container
    const container = elt( null, 'div',
        { class : 'container', style : 'padding: 1em;' } );
    // create tools for appending new settings sections as cards
    // that fit 3 per row and then wrap to the next row
    var cardCount = 0, rowInUse = null;
    const addSettingsSection = ( title, elts ) => {
        if ( cardCount % 3 == 0 )
            container.appendChild(
                rowInUse = elt( null, 'div', { class : 'row' } ) );
        rowInUse.appendChild( elt( null, 'div', { class : 'col-sm' },
            elt( null, 'div', { class : 'card border-primary' }, [
                elt( title, 'div', { class : 'card-header' } ),
                elt( null, 'div', { class : 'card-body' }, elts )
            ] ) ) );
        cardCount++;
    }
    // create the settings section for H-class size headings
    const updateHClassSizes = () =>
        setDiagramOption( 'showHClassSizes',
            getRadioGroupValue( 'hclass-size-options' ) );
    addSettingsSection( 'Show H-Class Headings', elt( null,
        'fieldset', { class : 'form-group' }, [
            radioButton( 'Always', 'yes', 'hclass-size-options',
                false, null, updateHClassSizes ),
            radioButton( 'When needed', 'if-hidden-elements',
                'hclass-size-options', true, null,
                updateHClassSizes ),
            radioButton( 'Never', 'no', 'hclass-size-options',
                false, null, updateHClassSizes )
        ] ) );
    // create the settings section for H-class sizes
    // (to do)
    // return the container that holds all the sections
    return container;
}

function wrapDiagram ( diagram ) {
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
    wrapper.appendChild( elt(
        `Egg-box Diagram for "${diagram.renderedFrom.name}"`,
        'h2' ) );
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
    wrapper.appendChild( diagram );
    wrapper.style.margin = '1em';
    return wrapper;
}

function renderEggBoxDiagram ( diagram ) {
    var result = elt( null, 'table',
        { border : 0, id : 'eggBoxDiagram' } );
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
    result.renderedFrom = diagram;
    return result;
}

function initializeSemigroup ( semigroup ) {
    // first setting must be one of:
    //   'yes' - always show sizes of H-classes
    //   'no' - never show them
    //   'if-hidden-elements' - show them iff there are too many
    // elements to display, so some are hidden behind an ellipsis
    semigroup.options.showHClassSizes = 'if-hidden-elements';
    // add pointers from each subobject to the whole semigroup
    // data structure, for convenience
    for ( var i = 0 ; i < semigroup.DClasses.length ; i++ ) {
        const dclass = semigroup.DClasses[i];
        dclass.semigroup = semigroup;
        dclass.options = {
            numHClassElementsToShow : semigroup.options.HLimit
        };
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

const diagramElement = () =>
    document.getElementById( 'eggBoxDiagram' );
const diagramModel = () => diagramElement().renderedFrom;
const updateDiagram = () =>
    diagramElement().parentNode.replaceChild(
        renderEggBoxDiagram( diagramModel() ), diagramElement() );
const setDiagramOption = ( key, value ) => {
    diagramModel().options[key] = value;
    updateDiagram();
}

window.VisualizationTools['egg-box'] =
function ( element, json, callback ) {
    const diagram = wrapDiagram( renderEggBoxDiagram(
        initializeSemigroup( JSON.parse( json.data ) ) ) );
    element.appendChild( diagram );
    callback( element, diagram );
};
