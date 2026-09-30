xquery version "3.1";

(:~
 : Page title and breadcrumb for the document view of "When the Wall Came Down".
 : Replaces the ODD-based title/breadcrumb modes, which would show the volume title.
 :)
module namespace wdoc="https://e-editiones.org/apps/wall-came-down/doc";

import module namespace wall="https://e-editiones.org/apps/wall-came-down/templates" at "wall.xqm";

declare namespace tei="http://www.tei-c.org/ns/1.0";

declare function wdoc:tei($context as map(*)) as element(tei:TEI)? {
    let $content := $context?doc?content
    return if (exists($content)) then (root($content)//tei:TEI)[1] else ()
};

(:~ Browser title: shortened document title, followed by the edition title :)
declare function wdoc:title($context as map(*)) as xs:string {
    let $doc := wdoc:tei($context)
    let $summary := if (exists($doc)) then wall:title($doc) else ""
    let $short :=
        if (string-length($summary) > 90) then
            replace(substring($summary, 1, 90), "\s+\S*$", "") || " …"
        else
            $summary
    return
        string-join(($short[. != ""], $context?label), " – ")
};

(:~
 : Browser title for every page (registered in templates/wall-blocks.html):
 : document view → shortened document title, register entry (people/…) → name of the
 : person, place or organisation, all other pages → the edition title.
 : The register overviews (people, places) define their own title block, which Jinks
 : would output in addition, so nothing is returned for them.
 :)
declare function wdoc:page-title($context as map(*)) as element(title)? {
    let $title := wdoc:page-title-text($context)
    return if (exists($title)) then <title>{ $title }</title> else ()
};

declare %private function wdoc:page-title-text($context as map(*)) as xs:string? {
    let $entity := $context?entity-data?root
    return
        if (exists($context?doc?content)) then
            wdoc:title($context)
        else if (exists($entity)) then
            let $name := normalize-space(head((
                $entity/tei:persName[@type = ('reg', 'main', 'full')],
                $entity/tei:placeName[@type = ('reg', 'main', 'full')],
                $entity/tei:orgName[@type = ('reg', 'main', 'full')],
                $entity/tei:persName, $entity/tei:placeName, $entity/tei:orgName
            )))
            return string-join(($name[. != ""], $context?label), " – ")
        else if (matches(request:get-uri(), "/(people|places|organizations)/?$")) then
            ()
        else
            string($context?label)
};

(:~
 : Previous / next document on the timeline (ordered by date of origin, as in the chronicle).
 : Rendered into the toolbar instead of the page navigation.
 :)
declare function wdoc:timeline-nav($context as map(*)) {
    let $doc := wdoc:tei($context)
    return
        if (empty($doc)) then
            ()
        else
            let $all := wall:documents()
            let $name := util:document-name($doc)
            let $pos := index-of($all ! util:document-name(.), $name)[1]
            let $prev := if ($pos > 1) then $all[$pos - 1] else ()
            let $next := if ($pos < count($all)) then $all[$pos + 1] else ()
            return
                <li class="wall-docnav">
                    <span role="group" class="light">
                        { wdoc:nav-link($prev, "prev") }
                        <span class="wall-docnav-pos">{ $pos } / { count($all) }</span>
                        { wdoc:nav-link($next, "next") }
                    </span>
                </li>
};

declare %private function wdoc:nav-link($target as element(tei:TEI)?, $dir as xs:string) {
    let $label := if ($dir = "prev") then "Earlier document" else "Later document"
    let $icon :=
        <svg class="ionicon" viewBox="0 0 512 512" aria-hidden="true">
            <path fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="48"
                d="{if ($dir = 'prev') then 'M328 112L184 256l144 144' else 'M184 112l144 144-144 144'}"/>
        </svg>
    let $hidden := <span class="visually-hidden"><pb-i18n key="wall.docnav.{$dir}">{ $label }</pb-i18n></span>
    return
        if (empty($target)) then
            <span class="wall-docnav-link disabled" aria-disabled="true">{
                if ($dir = "prev") then ($icon, <span class="date">–</span>) else (<span class="date">–</span>, $icon)
            }</span>
        else
            let $date := wall:date(wall:when($target))
            return
                <a class="wall-docnav-link {$dir}" href="{util:document-name($target)}" rel="{$dir}"
                    title="{wall:title($target)}">{
                    if ($dir = "prev") then ($icon, $hidden, <span class="date">{ $date }</span>)
                    else ($hidden, <span class="date">{ $date }</span>, $icon)
                }</a>
};

(:~ Breadcrumb entry: document type, date and Dodis number :)
declare function wdoc:breadcrumb($context as map(*)) {
    let $doc := wdoc:tei($context)
    let $type := wall:type($doc)
    return
        if (empty($doc)) then
            ()
        else
            <span class="wall-crumb">{
                if ($type) then (
                    <pb-i18n key="wall.label.{replace(lower-case($type), '\s+', '-')}">{ wall:label($type, "en") }</pb-i18n>,
                    " · "
                ) else (),
                wall:date(wall:when($doc)),
                " · dodis.ch/" || $doc//tei:msIdentifier/tei:idno/string()
            }</span>
};
