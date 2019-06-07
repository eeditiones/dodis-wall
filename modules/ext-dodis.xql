xquery version "3.1";

module namespace pmf="http://www.existsolutions.com/modules/dodis";

declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace config="http://www.tei-c.org/tei-simple/config" at "config.xqm";

declare function pmf:init($config as map(*), $node as node()*) {
    let $id := replace(util:document-name($node), "^(\d+).+$", "$1")
    let $metadata := util:binary-doc($config:app-root || "/metadata/" || $id || ".json")
    let $json := parse-json(util:binary-to-string($metadata))
    let $metadataXML := pmf:process-metadata($json)
    return
        map:merge(($config, map { "metadata": $json, "metadataXML": $metadataXML }))
};

declare function pmf:facsimile-links($config as map(*), $node as node(), $class as xs:string+) {
    let $pages := xs:integer($config?metadata?data?pagesCount)
    for $page in 0 to $pages - 1
    let $pagePart := if ($pages > 1) then "-" || $page else ()
    return
        <pb-facs-link facs="{$config?metadata?data?id}{$pagePart}.png"></pb-facs-link>
};

declare function pmf:process-metadata($json as map(*)*) {
    <div xmlns="http://www.tei-c.org/ns/1.0">
        <head>{$json?data?title}</head>
        <p rend="description">{ $json?data?summary }</p>
        <listPlace>
        {
            for $place in ($json?data?relatedPlaces?origin?*, $json?data?relatedPlaces?mention?*)
            return
                <place>
                    <placeName>{$place?name}</placeName>
                </place>
        }
        </listPlace>
    </div>
};
