xquery version "3.1";

module namespace idx="http://teipublisher.com/index";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace dbk="http://docbook.org/ns/docbook";

declare variable $idx:app-root :=
    let $rawPath := system:get-module-load-path()
    return
        (: strip the xmldb: part :)
        if (starts-with($rawPath, "xmldb:exist://")) then
            if (starts-with($rawPath, "xmldb:exist://embedded-eXist-server")) then
                substring($rawPath, 36)
            else
                substring($rawPath, 15)
        else
            $rawPath
    ;

(:~
 : Helper function called from collection.xconf to create index fields and facets.
 : This module needs to be loaded before collection.xconf starts indexing documents
 : and therefore should reside in the root of the app.
 :)
declare function idx:get-metadata($root as element(), $field as xs:string) {
    let $header := $root/tei:teiHeader
    let $json-doc-path := "/db/apps/dodis-facets/metadata/" || util:document-name($root) => replace("^(\d+).+$", "$1.json")
    let $json-doc :=  try { json-doc($json-doc-path) } catch * { () }
    let $fallback-values := 
        map { "data":
            map { 
                "langCode": "[no-metadata]", 
                "documentDate": "[no-metadata]",
                "relatedPersons": ()
            } 
        }
    return
        switch ($field)
            case "title" return
                string-join((
                    $header//tei:msDesc/tei:head, $header//tei:titleStmt/tei:title[@type = 'main'],
                    $header//tei:titleStmt/tei:title,
                    $root/dbk:info/dbk:title
                ), " - ")
            case "author" return (
                $header//tei:correspDesc/tei:correspAction/tei:persName,
                $header//tei:titleStmt/tei:author
            )
            case "language" return
                head((
                    if (exists($json-doc)) then $json-doc?data?language else (),
                    $header//tei:langUsage/tei:language/@ident,
                    $root/@xml:lang,
                    $header/@xml:lang
                ))
            case "date" return head((
                if (exists($json-doc)) then $json-doc?data?documentDate else (),
                $header//tei:correspDesc/tei:correspAction/tei:date/@when,
                $header//tei:sourceDesc/(tei:bibl|tei:biblFull)/tei:publicationStmt/tei:date,
                $header//tei:sourceDesc/(tei:bibl|tei:biblFull)/tei:date/@when,
                $header//tei:fileDesc/tei:editionStmt/tei:edition/tei:date,
                $header//tei:publicationStmt/tei:date
            ))
            case "genre" return (
                idx:get-genre($header),
                $root/dbk:info/dbk:keywordset[@vocab="#genre"]/dbk:keyword
            )
            case "persons-mentioned" return (
                if (exists($json-doc)) then 
                    if (map:contains($json-doc?data, "relatedPersons")) then 
                        $json-doc?data?relatedPersons?mention?*?fullName
                    else
                        "[none]"
                else 
                    ()
            )
            case "places-mentioned" return (
                if (exists($json-doc)) then 
                    if (map:contains($json-doc?data, "relatedPlaces")) then 
                        $json-doc?data?relatedPlaces?mention?*?name
                    else
                        "[none]"
                else
                    ()
            )
            case "organizations-mentioned" return (
                if (exists($json-doc)) then 
                    if (map:contains($json-doc?data, "relatedOrganizations")) then 
                        $json-doc?data?relatedOrganizations?mention?*?name
                    else
                        "[none]"
                else
                    ()
            )
            default return
                ()
};

declare function idx:get-genre($header as element()?) {
    for $target in $header//tei:textClass/tei:catRef[@scheme="#genre"]/@target
    let $category := id(substring($target, 2), doc($idx:app-root || "/data/taxonomy.xml"))
    return
        $category/ancestor-or-self::tei:category[parent::tei:category]/tei:catDesc
};
