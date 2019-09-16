# Workshop Graz Outline

## Preliminaries

* Make sure people have either installed docker image or eXist
* Upload ODD and a single doc for testing. Explain the UI
* Generate an application with dodis-graz.odd
* Upload the entire dataset

## ODD Editing

* open 49550: DDR - Neue Regierung und Politik
* move dateline to right
* exercise: make `emph` display in italic
* parameters: format date in dateline: format-date(@when, '[FNn], [D1o] [MNn], [Y]')

## Creating an HTML template

* save view.html as dodis.html
* explain webcomponents, including shadow DOM
* change config.xqm template setting
* upload background image and logo via eXide to resources/images/
* open templates/menu.html and change logo -> image appears distorted
* in dodis.html add CSS rule:

```css
.logo img {
    width: auto;
    height: auto;
}
```

* set background image on app-header:

```css
app-header {
    background-image: url(resources/images/bg-header.jpg);
}
```

to make background visible, we need to overwrite background-color as well:

```css
.toolbar {
    background-color: rgba(0, 0, 0, 0.6);
    color: white;
}

.menubar {
    background-color: rgba(0, 0, 0, 0.3);
    color: white;
}
```

Exercise: copy and paste changes to index.html as well.

## Explain how to download .xar

## Integrate facsimile

* Demonstrate webcomponent docs
* Add pb-facsimile to dodis.html (don't forget @subscribe="transcription", explain channels and events)
* Output pb-facs-link elements from ODD:
    * change config:default-view := "body" in config.xqm
    * add rule for body in ODD to output facsimile list from root(.)//facsimile
    * for graphic with parent::facsimile output pb-facs-link
* Adjust CSS:

```css
.content-body {
    display: flex;

    /* or: */
    display: grid;
    grid-template-columns: 1fr auto;
    grid-column-gap: 20px;
}

pb-facsimile {
    height: calc(100vh - 148px);
    flex: 1;
}
```

(flex numbers mean relative importance in relation to other components with flex value; thus adding it here we need to bump up the number on other components, e.g. #view1, cf. https://css-tricks.com/snippets/css/a-guide-to-flexbox/ vs https://css-tricks.com/snippets/css/complete-guide-grid/)

* let's also add some padding around the edges modifying the .content-body css

```css
.content-body {
  ...
  padding: 0 20px;
}
```

## Facets

* open collection.xconf and explain
* the two facets for genre and language are wrong, so fix them
    * open index.xql
    * change language case to just read `$header/tei:langUsage/tei:language`
    * change genre case to `$header//tei:textClass/tei:keywords/tei:term`
    * in collection.xconf remove hierarchical="yes" from genre field
    * open config.xqm and also remove hierarchical option from $config:facets
* add another facet for date:

```
tokenize($header//tei:msDesc/tei:history/tei:origin/@when, '-')
```

## Add side panel for people and places

* add another pb-view component to dodis.html template

```xml
<pb-view view='single' source='document1' subscribe='transcription' id='metadata'>
  <pb-param name='view' value='metadata'/>
</pb-view>
```

* to display it properly we need to style it

```CSS
 #metadata {
   flex: 1;
 }
```

* this outputs the transcription twice, so we need to make a distinction in the odd
* add another rule for TEI to pull only content from listPlace and listPerson for metadata view
  we also assign a metadata class so we have a hook to plug customized styling for this panel

```xml
<model predicate='$parameters?view='metadata' behaviour='block' cssClass='metadata'>
  <param name='content' value='teiHeader//listPerson | teiHeader//listPlace'/>
</model>
```


* then add ODD entry for listPerson

```xml
<modelSequence>
  <model behaviour="heading">
    <param name="content" value="'Persons'"/>
  </model>
  <model behaviour="list"/>
</modelSequence>
```
* and entry for the person element which now needs to be treated as a listItem

```xml
<model behaviour="listItem">
  <param name="content" value="persName[@type='full']"/>
</model>
```

* persName can be linked by adding link behaviour to persName

```xml
<model behaviour="link">
 <param name="uri" value="../idno"/>
 <param name="target" value="'_blank'"/>
</model>
 ```

The default list looks ugly so we need to:
  * change the css in `dodis.css`. This file
is already linked in ODD but doesn't exist so needs to be created in `resources/odd`.
NB this requires regenerating the ODD to have effect!
  * let's remove default underline for links as we're at it

 ```css
 .metadata ul {
  list-style: none;
  padding: 0;

 }

 .metadata a {
  text-decoration: none;
 }
 ```


* the content can be made prettier by adjusting to

`<param name="content" value="(persName[surname], ' (', birth, death, ')')"/>`

but that requires adding models for birth and death as well


Exercise: add places / organizations to the sidebar in a similar manner
