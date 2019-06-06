xquery version "3.1";

module namespace pmf="http://www.existsolutions.com/modules/dodis";

declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace config="http://www.tei-c.org/tei-simple/config" at "config.xqm";

declare function pmf:init($config as map(*), $node as node()*) {
    let $id := substring-before(util:document-name($node), ".xml")
    let $metadata := util:binary-doc($config:app-root || "/metadata/" || $id || ".json")
    let $json := parse-json(util:binary-to-string($metadata))
    return
        map:merge(($config, map { "metadata": $json }))
};

declare function pmf:facsimile-links($config as map(*), $node as node(), $class as xs:string+) {
    let $pages := xs:integer($config?metadata?data?pagesCount)
    for $page in 0 to $pages - 1
    let $pagePart := if ($pages > 1) then "-" || $page else ()
    return
        <pb-facs-link facs="{$config?metadata?data?id}{$pagePart}.png"></pb-facs-link>
};
