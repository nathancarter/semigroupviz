
// This visualization tool draws egg-box diagrams for semigroups, if
// passed the appropriate data in JSON form.
//
// The JSON data should have the following attributes:
// ( DOCUMENTATION TO-DO )

/*
 * Simple function for creating text in ellipses in English.
 * more(1,'thing') == "...1 more thing"
 * more(2,'thing') == "...2 more things"
 * more(2,'class') == "...2 more classes"
 */
function more ( num, type ) {
    return `...${num} more ${type}${num==1?'':/s$/.test(type)?'es':'s'}`;
}

/*
 * Utility function for building HTMLElement instances with various
 * attributes and contents.
 *  html - the inner HTML of the element to create
 *  tag - the type of the element to create, by tagname (e.g.,
 *    "P", which is the default)
 *  attrs - an object that functions as a key-value dictionary of
 *    attributes to add to the element after its creation, such as
 *    { style : 'margin: 0px;' }, etc.
 *  children - a list of child elements to append after creating the
 *    element and setting its inner HTML (thus these will be appended
 *    after any elements created by the html parameter); this can be
 *    a single element or an array of elements
 * Examples:
 * elt('hello') == <P>hello</P>
 * elt(null,'BR') == <BR/>
 * elt('Heading','H1',{style:'display:none;'},X)
 *   == <H1 style="display:none;">Heading</H1>
 *      plus whatever node X is appended after the text and before
 *      the close tag </H1>
 */
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

/*
 * Creates a TD element to place in a table representing a D-class.
 * The result of this function represents a single H-class within
 * that D-class; in particular, the H-class passed as parameter.
 * The H-class should be one of the objects in the semigroup being
 * rendered by this page; in particular, there should exist
 * indices i,j,k such that
 *   diagramModel().DClasses[i].RClasses[j].HClasses[k] == hclass.
 * The element will contain the names of 1 or more elements of the
 * given class, and all relevant options will be respected (such as
 * whether to print a heading stating how many elements there are).
 * If not all elements that are available are selected for display
 * by the current options, then the ellipsis printed in this cell
 * will be a link that changes the options to show them.
 * Also, clicking the main body of an H-class cell toggles that one
 * cell between brief and expanded view.  (Clicking the ellipses
 * expands all cells within a D-class.)
 */
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
    if ( numToShow < hclass.size ) {
        const text = showHSize ? '&vellip;'
            : more( hclass.size - numToShow, 'element' );
        const script = `showAll(${hclass.DClass.index},'H'); return false;`;
        const title = 'Click to expand all H-classes in this D-class.';
        eltsToShow.push(
            `<a href="#" onclick="${script}" title="${title}">${text}</a>` );
    }
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

/*
 * Creates a TR element to place in a table representing a D-class.
 * The result of this function represents a single R-class within
 * that D-class; in particular, the R-class passed as parameter.
 * The R-class should be one of the objects in the semigroup being
 * rendered by this page; in particular, there should exist
 * indices i,j such that
 *   diagramModel().DClasses[i].RClasses[j] == rclass.
 * The element will contain cells for 1 or more H-classes of the
 * given R-class, and all relevant options will be respected (most
 * important, how many such cells should be shown).
 * If not all H-classes that are available are selected for display
 * by the current options, then the ellipsis printed at the end of
 * the row will be a link that changes the options to show them.
 */
function renderRClass ( rclass ) {
    const options = rclass.semigroup.options;
    var result = elt( null, 'tr' );
    // render all the H-classes we've been asked to show by the
    // relevant option (recall that L-classes and H-classes are 1-1
    // inside a chosen R-class)
    const numToShow = rclass.DClass.options.numLClassesToShow;
    for ( var i = 0 ; i < numToShow ; i++ )
        result.appendChild( renderHClass( rclass.HClasses[i], options ) );
    // if we didn't show all of them, create a cell with a "...more"
    // message and make it a link that shows the missing cells
    if ( numToShow < rclass.size ) {
        const otherHClassReps = rclass.HClasses.map( hclass =>
            hclass.representative ).join( '\n' );
        const text = more( rclass.size - numToShow, 'H-class' );
        const script = `showAll(${rclass.DClass.index},'L'); return false;`;
        const title = 'Click to expand all R-classes in this D-class.';
        const moreCell = elt(
            `<a href="#" onclick="${script}" title="${title}">${text}</a>`,
            'td', {
                title : 'Representatives of other\nH-classes '
                      + 'in this R-class:\n' + otherHClassReps
            }
        );
        result.appendChild( moreCell );
    }
    return result;
}

/*
 * Creates a table element representing a D-class.
 * The result of this function represents a single D-class within
 * the semigroup; in particular, the D-class passed as parameter.
 * The D-class should be one of the objects in the semigroup being
 * rendered by this page; in particular, there should exist an
 * index i such that diagramModel().DClasses[i] == dclass.
 * The element will contain rows for 1 or more R-classes of the
 * given D-class, and all relevant options will be respected (most
 * important, how many such rows should be shown).
 * If not all R-classes that are available are selected for display
 * by the current options, then the ellipsis printed at the bottom
 * the table will be a link that changes the options to show them.
 */
function renderDClass ( dclass ) {
    const options = dclass.semigroup.options;
    var result = elt( null, 'table', { class : 'd-class table-bordered' } );
    // render all the R-classes we've been asked to show by the
    // relevant option (one per row)
    const numToShow = dclass.options.numRClassesToShow;
    for ( var i = 0 ; i < numToShow ; i++ )
        result.appendChild( renderRClass( dclass.RClasses[i], options ) );
    // if we didn't show all of them, create a row with a "...more"
    // message and make it a link that shows the missing rows
    if ( numToShow < dclass.size ) {
        var rowLength = dclass.options.numLClassesToShow;
        if ( rowLength < dclass.RClasses[0].size ) rowLength++;
        const otherRClassReps = dclass.RClasses.map( rclass =>
            rclass.HClasses[0].representative ).join( '\n' );
        const text = more( dclass.size - numToShow, 'R-class' );
        const script = `showAll(${dclass.index},'R'); return false;`;
        const title = 'Click to see all available rows in this D-class.';
        const moreCell = elt(
            `<a href="#" onclick="${script}" title="${title}">${text}</a>`,
            'td', {
                colspan : rowLength,
                title : 'Representatives of other\nR-classes '
                      + 'in this D-class:\n' + otherRClassReps
            }
        );
        result.appendChild( elt( null, 'tr', null, moreCell ) );
    }
    return result;
}

/*
 * Utility function for creating HTML radio buttons.
 *   text - the text to display next to the button, as a string
 *   value - the text to use as the radio group's value if this
 *     button is the one checked
 *   category - a name for the radio group to which this belongs,
 *     so it is possible to look up the value of the group later
 *   checked - boolean, whether this is the one checked
 *   id - the ID of the HTML element to generate, as a string
 *   cb - an optional callback function to be called whenever the
 *     radio button changes
 */
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
/*
 * Assuming radio buttons have been created and placed in the
 * document using the radioButton() function above, then they each
 * have an assigned category, thus partitioning them into groups.
 * Given that category name as a string, this function looks up
 * which radio button in the group is checked, and returns its
 * value as a string.
 */
const getRadioGroupValue = ( category ) => {
    const theOne = Array.prototype.slice.apply(
        document.getElementsByTagName( 'input' )
    ).find( button =>
        button.getAttribute( 'type' ) == 'radio'
     && button.getAttribute( 'name' ) == category
     && button.checked );
    return theOne ? theOne.getAttribute( 'value' ) : undefined;
}

/*
 * Utility function for building two-column forms using Bootstrap
 * tools.
 * Arguments should be an even-numbered list, where for every even
 * number i, we have that arguments[i] is a string that appears in
 * the left column to explain/prompt the user's input, and
 * arguments[i+1] is an HTMLElement to be placed in the right-hand
 * column across from that prompt, either an input element or a
 * DIV containing several such elements.
 * (The label can actually be any element, but if it's a string,
 * this will automatically wrap it in a paragraph tag for you.)
 */
function form ( /* arguments */ ) {
    const result = elt( null, 'form', { class : 'form-horizontal' } );
    for ( var i = 0 ; i < arguments.length - 1 ; i += 2 ) {
        // create the label if necessary
        var label = arguments[i];
        if ( typeof( label ) == 'string' ) label = elt( label, 'label' );
        // connect the label to the control
        const control = arguments[i+1];
        const id = control.getAttribute( 'id' )
                || control.childNodes[1].getAttribute( 'id' );
        label.setAttribute( 'for', id );
        // append the label-control pair to the growing form
        result.appendChild( elt( null, 'div', {
            class : 'row', style : 'padding-bottom: 1em;'
        }, [
            elt( null, 'div', { class : 'col' }, label ),
            elt( null, 'div', { class : 'col' }, control )
        ] ) );
        // append an invisible warning message that you can later
        // reveal with the functions below if there is something wrong
        // with this component of the form
        result.appendChild( elt( null, 'div', {
            class : 'row', style : 'padding-bottom: 1em;'
        }, [
            elt( '', 'div', {
                class : 'col alert alert-primary',
                id : id + 'Warning',
                style : 'display : none;'
            } )
        ] ) );
    }
    return result;
}

/*
 * As you can see in the comments inside the previous function,
 * form components come with invisible warnings that can be shown
 * if something is wrong with that component of the form.
 * To do so, call this function.
 *   warningId - When you create a form control with id X,
 *     its corresponding warning control has id XWarning
 *     (e.g., "username" -> "usernameWarning").  Pass that
 *     warning ID here to reveal the correct warning box.
 *   html - the inner HTML to use for filling the warning box
 *     (which is just a DIV with the appropriate styles to look
 *     like a warning)
 */
function showWarning ( warningId, html ) {
    const warning = document.getElementById( warningId );
    warning.innerHTML = html;
    warning.style.display = 'block';
}
/*
 * The reverse of the previous function.
 * To understand the parameter, see the documentation for
 * that function.
 */
function hideWarning ( warningId ) {
    const warning = document.getElementById( warningId );
    warning.style.display = 'none';
}

/*
 * A function that creates the entire block of settings controls
 * that the user can reveal above the egg-box diagram by clicking
 * the gear icon in the upper right corner of the visualization.
 * This contains settings for the entire diagram in a box on the
 * left, plus settings for the individual D-classes with the
 * diagram in a box on the right.  The resulting controls are all
 * placed in a single HTML DIV Element and returned by this
 * function (hence its name).
 * Note that this function does not initialize these controls to
 * their default values.  See the subsequent function,
 * setupControlsFromModel(), for that functionality.
 * It is a complex enough function that it begins with several
 * internal utility functions for its own use.
 */
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
    // create tools for creating sliders with counters above them,
    // which read to and write from certain settings within diagramModel()
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
                display( letter ).textContent = slider( letter ).value;
                ( ( letter == 'd' ) ? diagramModel()
                                    : diagramModel().DClasses[picker.value] )
                    .setOption( key, slider( letter ).value );
            }
        } )
    ] );
    // create the settings section for the diagram as a whole
    startNewRow();
    const updateHClassSizes = () =>
        diagramModel().setOption( 'showHClassSizes',
            getRadioGroupValue( 'hclass-size-options' ) );
    addColumn(
        card( 'General options', form(
            'Show this many D-classes:',
            makePair( 'd', 'numDClassesToShow' ),
            'When to show H-class headings:',
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
    // create the settings section for individual D-classes
    addColumn( card( 'Options for each D-class', form(
        // this section must necessarily begin with a chooser
        // that the user manipulates to indicate which D-class
        // they want to edit the settings for
        'Choose a D-class by representative:',
        picker = elt( null, 'select', {
            class : 'form-control',
            id : 'chooseDClass',
            // when the user chooses a D-class, we must then
            // update all the other controls in the section,
            // to reflect the current state of the options for
            // the D-class just selected (because they were
            // probably just moments ago reflecting the staet of
            // a different D-class)
            change : ( event ) => {
                // get the new D-class the user just chose
                const dclass = diagramModel().DClasses[picker.value]
                // how to update a slider-display pair
                const updatePair = ( letter, optionkey, maxkey ) => {
                    const option = dclass.getOption( optionkey );
                    const max = dclass.getOption( maxkey );
                    slider( letter ).setAttribute( 'max', max );
                    slider( letter ).disabled = max == 1;
                    display( letter ).textContent =
                        slider( letter ).value = option;
                }
                // force updating of each slider-display pair
                updatePair( 'r', 'numRClassesToShow', 'numRClasses' );
                updatePair( 'l', 'numLClassesToShow', 'numLClasses' );
                updatePair( 'h', 'numHClassElementsToShow', 'numElements' );
                // show any relevant warnings related to those sliders:
                // 1. Are there R-classes in this D-class that weren't
                //    included in the JSON data passed to this page?
                //    If so, tell the user, so they know why we can't
                //    present them the option to view them all.
                if ( dclass.size > dclass.RClasses.length )
                    showWarning( 'sliderForRWarning', 'The selected '
                      + `D-class contains ${dclass.size} R-classes, `
                      + 'but the GAP code that created this visualization '
                      + 'chose to include in this page the data for only '
                      + `${dclass.RClasses.length} of them.` );
                else
                    hideWarning( 'sliderForRWarning' );
                // 2. Are there H-classes in this D-class's R-classes
                //    that weren't included in the JSON data passed to
                //    this page?  If so, tell the user, so they know why
                //    we can't present them the option to view them all.
                if ( dclass.RClasses[0].size >
                        dclass.RClasses[0].HClasses.length )
                    showWarning( 'sliderForLWarning', 'The selected '
                      + `D-class contains ${dclass.RClasses[0].size} `
                      + 'R-classes, but the GAP code that created this '
                      + 'visualization chose to include in this page '
                      + 'the data for only '
                      + `${dclass.RClasses[0].HClasses.length} of them.` );
                else
                    hideWarning( 'sliderForLWarning' );
                // 3. Are there elements in this D-class's H-classes
                //    that weren't included in the JSON data passed to
                //    this page?  If so, tell the user, so they know why
                //    we can't present them the option to view them all.
                if ( dclass.RClasses[0].HClasses[0].size >
                        dclass.RClasses[0].HClasses[0].elements.length )
                    showWarning( 'sliderForHWarning', 'The selected '
                      + 'D-class contains H-classes with '
                      + `${dclass.RClasses[0].HClasses[0].size} elements `
                      + 'each, but the GAP code that created this '
                      + 'visualization chose to include in this page '
                      + 'the data for only '
                      + dclass.RClasses[0].HClasses[0].elements.length
                      + ' elements in each H-class.' );
                else
                    hideWarning( 'sliderForHWarning' );
            }
        } ),
        // create sliders that let the user choose how many R-classes,
        // L-classes, and H-class elements to show within this D-class.
        'Then how many of its R-classes to show:',
        makePair( 'r', 'numRClassesToShow' ),
        'And how many of its L-classes to show:',
        makePair( 'l', 'numLClassesToShow' ),
        'And how many elements should be shown in its H-classes:',
        makePair( 'h', 'numHClassElementsToShow' )
    ) ) );
    // return the container that holds all the settings sections
    return container;
}

/*
 * This function is called after the semigroup is loaded and after the
 * diagram controls have been set up and included in the page.
 * Thus this function can depend upon both the model and the view
 * being accessible.
 * It initializes the controls to their default values,
 * as promised in the documentation for diagramControlsDiv().
 */
function setupControlsFromModel () {
    const model = diagramModel();
    // fill drop-down list with all D-class representatives
    const dClassChooser = document.getElementById( 'chooseDClass' );
    model.DClasses.map( ( dclass, index ) => {
        const repr = dclass.RClasses[0].HClasses[0].representative;
        dClassChooser.appendChild( elt(
            `Class #${index+1}:  ${repr}`, 'option', { value : index } ) );
    } );
    // tell it that it changed so it will set up all other controls
    document.getElementById( 'chooseDClass' ).dispatchEvent(
        new Event( 'change' ) );
    // set up slider for number of D-classes
    const max = model.options.NrDClassesIncluded > 0 ?
        Math.min( model.options.NrDClassesIncluded,
                  model.DClasses.length ) :
        model.DClasses.length;
    var slider = document.getElementById( 'sliderForD' );
    slider.setAttribute( 'max', max );
    slider.disabled = max == 1;
    document.getElementById( 'numDToShow' ).textContent =
        slider.value = model.getOption( 'numDClassesToShow' );
    // add warnings for any data that GAP didn't include in the JSON
    if ( model.size > model.DClasses.length )
        showWarning( 'sliderForDWarning', 'The semigroup contains '
          + `${model.size} D-classes, but the GAP code that created `
          + 'this visualization chose to include in this page the '
          + `data for only ${model.DClasses.length} of them.` );
    else
        hideWarning( 'sliderForDWarning' );
}

/*
 * The following function can be called in any of several ways:
 *   showAll() - no parameters - reveals all D-classes that were
 *     included in the JSON passed to this page, and updates the
 *     controls in the settings panel to reflect the change.
 *   showAll(n,'R') - n an index into the list of D-classes in the
 *     semigroup (0 <= n < numDClasses) - shows all the R-classes
 *     in the D-class with index n (here "all" means all whose
 *     data we have available; the semigroup may be larger than
 *     the JSON data passed to us)
 *   showAll(n,'L') - similar to previous, but for L-classes in the
 *     D-class with index n
 *   showAll(n,'H') - similar to previous, but for showing all the
 *     elements in all H-classes in the D-class with index n
 */
function showAll ( dclassIndex, classLetter ) {
    if ( dclassIndex == null ) {
        // they want to show all the D-classes to which we have access,
        // just change the options in the model and it will automatically
        // update the view
        diagramModel().setOption( 'numDClassesToShow',
            diagramModel().getOption( 'NrDClassesIncluded' ) );
    } else {
        // if they want to show all the R/L/H-classes inside this D-class,
        // just change the options in the model and then below when we
        // trigger a change event in the D-class chooser, it will update
        // the view
        const dclass = diagramModel().DClasses[dclassIndex];
        if ( classLetter == 'R' || classLetter == 'L' )
            dclass.setOption( `num${classLetter}ClassesToShow`,
                dclass.getOption( `num${classLetter}Classes` ) );
        else if ( classLetter == 'H' )
            dclass.setOption( 'numHClassElementsToShow',
                dclass.getOption( 'numElements' ) );
    }
    document.getElementById( 'chooseDClass' ).dispatchEvent(
        new Event( 'change' ) );
}

/*
 * This function takes an HTMLElement representing an egg-box diagram
 * for a semigroup and wraps it in a few useful things, including:
 *   - a title
 *   - a settings icon on the right side of the title, for exposing
 *     the settings controls created by diagramControlsDiv(), above
 *   - a scoped stylesheet, affecting only the diagram, so that if this
 *     is used within, say, a Jupyter notebook, the styles will not
 *     bleed out to the rest of the page
 */
function wrapDiagram ( diagram ) {
    const wrapper = elt( null, 'div' );
    // create the scoped stylesheet
    wrapper.innerHTML =
        '<style scoped>\n'
      + '@import url( "https://bootswatch.com/4/yeti/bootstrap.min.css" );\n'
      + '@import url( "https://use.fontawesome.com/releases/v5.7.2/css/all.css" );\n'
      + '.d-class td {\n'
      + '  border: 2px solid #999;\n'
      + '  padding: 0.5em 1em 0.5em 1em;\n'
      + '}\n'
      + '</style>';
    // create the title heading
    wrapper.appendChild( elt(
        `Egg-box Diagram for "${diagram.renderedFrom.name}"`,
        'h2' ) );
    // create the gear icon for showing the settings div
    const exposer = elt( '<i class="fas fa-cog"></i>', 'button', {
        class : 'btn btn-primary',
        type : 'button',
        style : 'position: absolute; top: 0.5em; right: 0.5em'
    } );
    // create the settings div and hide it
    const controls = diagramControlsDiv();
    controls.style.display = 'none'
    // when they click the gear icon, toggle settings display
    exposer.addEventListener( 'click', function ( event ) {
        if ( controls.style.display == 'none' ) {
            controls.style.display = 'block';
        } else {
            controls.style.display = 'none';
        }
    } );
    // put everything in the wrapper
    wrapper.appendChild( exposer );
    wrapper.appendChild( controls );
    wrapper.appendChild( diagram );
    wrapper.style.margin = '1em';
    return wrapper;
}

/*
 * "one-hot" encoding refers to a vector containing one entry
 * equal to 1 and the rest equal to 0.
 * so a "one-hot" table row is a TR element with all empty TDs
 * except for one.
 *   content - the content to put in the nonempty TD
 *   index - the index of the nonempty TD (zero-based) within
 *     the row
 *   length - the length of the row
 */
function oneHotTableRow ( content, index, length ) {
    var result = elt( null, 'tr' );
    var cell = elt( null, 'td', null, content );
    for ( var i = 0 ; i < length ; i++ )
        result.appendChild( i == index ? cell : elt( null, 'td' ) );
    return result;
}

/*
 * Take a semigroup as input (with whatever options were passed to
 * us from GAP) and generate a diagram.  Return the resulting diagram
 * as an HTML DIV Element.  The result will later be wrapped using
 * the wrapDiagram() function defined above.
 */
function renderEggBoxDiagram ( diagram ) {
    // the result is a table because the diagram is a grid
    var result = elt( null, 'table',
        { border : 0, id : 'eggBoxDiagram' } );
    // for each D-cell we should show...
    const numToShow = diagram.getOption( 'numDClassesToShow' );
    const tableSize = numToShow + ( numToShow < diagram.size ? 1 : 0 );
    // represent it using a "one-hot" table row,
    // as documented in the oneHotTableRow() function, above.
    for ( var i = 0 ; i < numToShow ; i++ )
        result.appendChild( oneHotTableRow(
            renderDClass( diagram.DClasses[i], diagram.options ),
            i, tableSize ) );
    // add an ellipsis to the end if there are rows we have not
    // shown, making it a link to disclose them if possible.
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
    // in the HTML element, embed the semigroup data itself,
    // for later lookup by any function in this page
    result.renderedFrom = diagram;
    return result;
}

/*
 * Fetch the element that is the rendered egg box diagram.
 */
const diagramElement = () =>
    document.getElementById( 'eggBoxDiagram' );
/*
 * From that element, fetch the embedded semigroup model.
 */
const diagramModel = () => diagramElement().renderedFrom;

/*
 * A semigroup is given to us by GAP as JSON data, of necessity,
 * because we are using the JupyterViz package under the hood,
 * which requires us to form our data into JSON.
 * But it is convenient if our structure were to be able to have
 * some circular references (e.g., an H-class having a pointer to
 * the D-class containing it).  This function traverses the
 * semigroup and sets up such circular references, as well as the
 * default values for any options that haven't already been set.
 */
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
        Math.max( 1, semigroup.options.NrDClassesIncluded );
    // add pointers from each subobject to the whole semigroup
    // data structure, for convenience
    semigroup.DClasses.map( ( dclass, index ) => {
        // let the D-class know its index, and about the whole semigroup
        dclass.index = index;
        dclass.semigroup = semigroup;
        // set up the class's default options
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
        // loop through its R-classes and their H-classes,
        // setting up references to parent, grandparent, etc. structures
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
    // add functionality for querying/updating options,
    // with automatic re-rendering of the diagram when options change
    semigroup.update = () =>
        diagramElement().parentNode.replaceChild(
            renderEggBoxDiagram( semigroup ), diagramElement() );
    semigroup.setOption = ( key, value ) => {
        console.log( 'setting diagram option', key, value );
        semigroup.options[key] = value;
        semigroup.update();
    };
    semigroup.getOption = key => semigroup.options[key];
    // not only can you set options in the diagram, but in any D-class
    // locally as well
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

/*
 * Finally, we can install the visualization tool that is this file's
 * purpose in life.  We create a new visualization tool and install it,
 * called "egg-box," that composes all the functions defined above,
 * including initializing the semigroup data structure, rendering the
 * diagram, wrapping it as needed, and setting up the default state of
 * all the settings controls.  The parameters below (including the use
 * of the callback) are as required by the JupyterViz package.
 */
window.VisualizationTools['egg-box'] =
function ( element, json, callback ) {
    const diagram = wrapDiagram( renderEggBoxDiagram(
        initializeSemigroup( JSON.parse( json.data ) ) ) );
    element.appendChild( diagram );
    setupControlsFromModel();
    callback( element, diagram );
};
