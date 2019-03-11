
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
                if ( typeof( attrs[key] ) != 'function' )
                    result.setAttribute( key, attrs[key] );
                else
                    result.addEventListener( key, attrs[key] );
    if ( html ) result.innerHTML = html;
    if ( children ) {
        if ( !( children instanceof Array ) )
            children = [ children ];
        children.map( c => result.appendChild( c ) );
    }
    return result;
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
    const numToShow = hclass.DClass.getOption(
        'numHClassElementsToShow' );
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
    // make the two views have the hand cursor, and swap
    // between one another.
    const toggleViews = () => {
        if ( defaultView.style.display == 'none' ) {
            defaultView.style.display = 'block';
            expandedView.style.display = 'none';
        } else {
            defaultView.style.display = 'none';
            expandedView.style.display = 'block';
        }
    }
    defaultView.addEventListener( 'click', toggleViews );
    expandedView.addEventListener( 'click', toggleViews );
    defaultView.style.cursor = 'pointer';
    expandedView.style.cursor = 'pointer';
    // put both views into the result, but hide one
    var result = elt( null, 'td', { class : 'table-active' },
        [ defaultView, expandedView ] );
    expandedView.style.display = 'none';
    return result;
}

function renderRClass ( rclass ) {
    const options = rclass.semigroup.options;
    var result = elt( null, 'tr' );//, { class : 'table-active' } );
    const numToShow = rclass.DClass.options.numLClassesToShow;
    for ( var i = 0 ; i < numToShow ; i++ )
        result.appendChild( renderHClass( rclass.HClasses[i], options ) );
    if ( numToShow < rclass.size ) {
        const otherHClassReps = rclass.HClasses.map( hclass =>
            hclass.representative ).join( '\n' );
        const moreCell = elt(
            more( rclass.size - numToShow, 'H-class' ), 'td', {
                title : 'Representatives of other\nH-classes '
                      + 'in this R-class:\n' + otherHClassReps
            }
        );
        result.appendChild( moreCell );
    }
    return result;
}

function renderDClass ( dclass ) {
    console.log( dclass );
    const options = dclass.semigroup.options;
    var result = elt( null, 'table', { class : 'd-class table-bordered' } );
    const numToShow = dclass.options.numRClassesToShow;
    for ( var i = 0 ; i < numToShow ; i++ )
        result.appendChild( renderRClass( dclass.RClasses[i], options ) );
    if ( numToShow < dclass.size ) {
        var rowLength = dclass.options.numLClassesToShow;
        if ( rowLength < dclass.RClasses[0].size ) rowLength++;
        const otherRClassReps = dclass.RClasses.map( rclass =>
            rclass.HClasses[0].representative ).join( '\n' );
        const moreCell = elt(
            more( dclass.size - numToShow, 'R-class' ), 'td', {
                colspan : rowLength,
                title : 'Representatives of other\nR-classes '
                      + 'in this D-class:\n' + otherRClassReps
            }
        );
        result.appendChild( elt( null, 'tr', null, moreCell ) );
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

function form ( /* arguments */ ) {
    const result = elt( null, 'form', { class : 'form-horizontal' } );
    for ( var i = 0 ; i < arguments.length - 1 ; i += 2 ) {
        var label = arguments[i];
        if ( typeof( label ) == 'string' ) label = elt( label, 'label' );
        const control = arguments[i+1];
        label.setAttribute( 'for', control.getAttribute( 'id' ) );
        result.appendChild( elt( null, 'div', {
            class : 'row', style : 'padding-bottom: 1em;'
        }, [
            elt( null, 'div', { class : 'col' }, label ),
            elt( null, 'div', { class : 'col' }, control )
        ] ) );
    }
    return result;
}

function diagramControlsDiv () {
    // make big settings container
    const container = elt( null, 'div',
        { class : 'container', style : 'padding: 1em;' } );
    // create tools for appending new settings sections as cards
    // that fit 3 per row and then wrap to the next row
    var rowInUse = null;
    const startNewRow = () => container.appendChild(
        rowInUse = elt( null, 'div', { class : 'row' } ) );
    function addColumn ( /* contents... */ ) {
        rowInUse.appendChild( elt( null, 'div', { class : 'col-sm' },
            Array.prototype.slice.apply( arguments ) ) );
    }
    const card = ( title, elts ) =>
        elt( null, 'div', { class : 'card border-primary' }, [
            elt( title, 'div', { class : 'card-header' } ),
            elt( null, 'div', { class : 'card-body' }, elts )
        ] );
    var picker;
    const displayName = letter => `num${letter.toUpperCase()}ToShow`;
    const sliderName = letter => `sliderFor${letter.toUpperCase()}`;
    const display = letter => document.getElementById( displayName( letter ) );
    const slider = letter => document.getElementById( sliderName( letter ) );
    const makePair = ( letter, key ) => elt( null, 'div', null, [
        elt( '', 'div', {
            style : 'text-align: center;',
            id : displayName( letter )
        } ),
        elt( null, 'input', {
            type : 'range',
            class : 'form-control-range',
            id : sliderName( letter ),
            min : 1, max : 2, value : 1, // these are changed later
            input : ( event ) => {
                console.log( letter, key, 'slider moved' );
                display( letter ).textContent = slider( letter ).value;
                ( ( letter == 'd' ) ? diagramModel()
                                    : diagramModel().DClasses[picker.value] )
                    .setOption( key, slider( letter ).value );
            }
        } )
    ] );
    // create the settings section for number of D-classes to show
    // and the settings section for H-class size headings
    startNewRow();
    const updateHClassSizes = () =>
        diagramModel().setOption( 'showHClassSizes',
            getRadioGroupValue( 'hclass-size-options' ) );
    addColumn(
        card( 'General options', form(
            'Show this many D-classes:',
            makePair( 'd', 'numDClassesToShow' ),
            'When to show H-class Headings:',
            elt( null, 'fieldset', { class : 'form-group' }, [
                radioButton( 'Always', 'yes', 'hclass-size-options',
                    false, null, updateHClassSizes ),
                radioButton( 'When needed', 'if-hidden-elements',
                    'hclass-size-options', true, null,
                    updateHClassSizes ),
                radioButton( 'Never', 'no', 'hclass-size-options',
                    false, null, updateHClassSizes )
            ] )
        ) )
    );
    // create the settings section for H-class sizes
    addColumn( card( 'Options for each D-class', form(
        'Choose a D-class by representative:',
        picker = elt( null, 'select', {
            class : 'form-control',
            id : 'chooseDClass',
            change : ( event ) => {
                // how to update a slider and display pair
                const updatePair = ( letter, optionkey, maxkey ) => {
                    const dclass = diagramModel().DClasses[picker.value]
                    const option = dclass.getOption( optionkey );
                    const max = dclass.getOption( maxkey );
                    slider( letter ).setAttribute( 'max', max );
                    slider( letter ).disabled = max == 1;
                    display( letter ).textContent =
                        slider( letter ).value = option;
                }
                // update each slider-display pair
                updatePair( 'r', 'numRClassesToShow', 'numRClasses' );
                updatePair( 'l', 'numLClassesToShow', 'numLClasses' );
                updatePair( 'h', 'numHClassElementsToShow', 'numElements' );
            }
        } ),
        'Then how many of its R-classes to show:',
        makePair( 'r', 'numRClassesToShow' ),
        'And how many of its L-classes to show:',
        makePair( 'l', 'numLClassesToShow' ),
        'And how many elements should be shown in its H-classes:',
        makePair( 'h', 'numHClassElementsToShow' )
    ) ) );
    // return the container that holds all the sections
    return container;
}

function setupControlsFromModel () {
    const dClassChooser = document.getElementById( 'chooseDClass' );
    diagramModel().DClasses.map( ( dclass, index ) => {
        const repr = dclass.RClasses[0].HClasses[0].representative;
        dClassChooser.appendChild( elt(
            `Class #${index+1}:  ${repr}`, 'option', { value : index } ) );
    } );
    document.getElementById( 'chooseDClass' ).dispatchEvent(
        new Event( 'change' ) );
    const max = diagramModel().options.NrDClassesIncluded > 0 ?
        Math.min( diagramModel().options.NrDClassesIncluded,
                  diagramModel().DClasses.length ) :
        diagramModel().DClasses.length;
    var slider = document.getElementById( 'sliderForD' );
    slider.setAttribute( 'max', max );
    slider.disabled = max == 1;
    document.getElementById( 'numDToShow' ).textContent =
        slider.value = diagramModel().getOption( 'numDClassesToShow' );
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
    const numToShow = diagram.getOption( 'numDClassesToShow' );
    const tableSize = numToShow + ( numToShow < diagram.size ? 1 : 0 );
    for ( var i = 0 ; i < numToShow ; i++ )
        result.appendChild( oneHotTableRow(
            renderDClass( diagram.DClasses[i], diagram.options ),
            i, tableSize ) );
    if ( numToShow < tableSize ) {
        const otherDClassReps = diagram.DClasses.map( dclass =>
            dclass.RClasses[0].HClasses[0].representative )
            .join( '\n' );
        result.appendChild( oneHotTableRow(
            elt( more( diagram.size - numToShow, 'D-class' ), 'td', {
                title : 'Representatives of other\nD-classes '
                      + 'in this semigroup:\n' + otherDClassReps
            } ),
            numToShow, tableSize ) );
    }
    result.renderedFrom = diagram;
    return result;
}

const diagramElement = () =>
    document.getElementById( 'eggBoxDiagram' );
const diagramModel = () => diagramElement().renderedFrom;

function initializeSemigroup ( semigroup ) {
    // first setting must be one of:
    //   'yes' - always show sizes of H-classes
    //   'no' - never show them
    //   'if-hidden-elements' - show them iff there are too many
    // elements to display, so some are hidden behind an ellipsis
    semigroup.options.showHClassSizes = 'if-hidden-elements';
    // since the Nr*Classes* settings might be 0, which implies that
    // everything should be included,
    semigroup.options.numDClassesToShow =
        semigroup.options.NrDClassesIncluded;
    // add pointers from each subobject to the whole semigroup
    // data structure, for convenience
    semigroup.DClasses.map( dclass => {
        dclass.semigroup = semigroup;
        dclass.options = {
            numRClasses : dclass.RClasses.length,
            numLClasses : dclass.RClasses[0].HClasses.length,
            numElements : dclass.RClasses[0].HClasses[0].elements.length
        };
        dclass.options.numRClassesToShow =
            Math.min( 5, dclass.options.numRClasses );
        dclass.options.numLClassesToShow =
            Math.min( 5, dclass.options.numLClasses );
        dclass.options.numHClassElementsToShow =
            Math.min( 5, dclass.options.numElements );
        dclass.RClasses.map( rclass => {
            rclass.DClass = dclass;
            rclass.semigroup = semigroup;
            rclass.HClasses.map( hclass => {
                hclass.RClass = rclass;
                hclass.DClass = dclass;
                hclass.semigroup = semigroup;
            } );
        } );
    } );
    // add functionality for querying/updating options and re-rendering
    semigroup.update = () =>
        diagramElement().parentNode.replaceChild(
            renderEggBoxDiagram( semigroup ), diagramElement() );
    semigroup.setOption = ( key, value ) => {
        console.log( 'setting diagram option', key, value );
        semigroup.options[key] = value;
        semigroup.update();
    };
    semigroup.getOption = key => semigroup.options[key];
    semigroup.DClasses.map( dclass => {
        dclass.setOption = ( key, value ) => {
            console.log( 'setting dclass option', key, value );
            dclass.options[key] = value;
            semigroup.update();
        };
        dclass.getOption = key => dclass.options[key];
    } );
    return semigroup;
}

window.VisualizationTools['egg-box'] =
function ( element, json, callback ) {
    const diagram = wrapDiagram( renderEggBoxDiagram(
        initializeSemigroup( JSON.parse( json.data ) ) ) );
    element.appendChild( diagram );
    setupControlsFromModel();
    callback( element, diagram );
};
