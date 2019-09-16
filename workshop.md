# Workshop Graz Outline

## Preliminaries

* Make sure people have either installed docker image or eXist
* Upload ODD and a single doc for testing. Explain the UI
* Generate an application with dodis-graz.odd
* Upload the entire dataset

## ODD Editing

* open 49550: DDR - Neue Regierung und Politik
* move dateline to right
* exercise: make <emph> display in italic
* parameters: format date in dateline: format-date(@when, '[FNn], [D1o] [MNn], [Y]')

## Creating an HTML template

* save view.html as dodis.html
* explain webcomponents
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

## Integrate facsimile

* Demonstrate webcomponent docs
* Add pb-facsimile to dodis.html
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
    min-width: 640px;
}
```
