xquery version "3.1";

module namespace idx="http://teipublisher.com/index";

declare namespace tei="http://www.tei-c.org/ns/1.0";

(:~
 : Helper function called from collection.xconf to create index fields and facets.
 : This module needs to be loaded before collection.xconf starts indexing documents
 : and therefore should reside in the root of the app.
 :)
declare function idx:get-metadata($root as element(), $field as xs:string) {
    let $header := $root/tei:teiHeader
    return
        switch ($field)
            case "title" return
                $header//tei:msDesc/tei:head
            case "author" return
                (
                    for $ref in $header//tei:correspAction[@type="sent"]/tei:persName/@ref
                        return 
                            id(substring-after($ref, '#'), root($root))//tei:persName[@type='full'],
                    for $ref in $header//tei:correspAction[@type="sent"]/tei:orgName/@ref
                        return
                            id(substring-after($ref, '#'), root($root))//tei:orgName
                )
            case "author-person" return
                for $ref in $header//tei:correspAction[@type="sent"]/tei:persName/@ref
                return 
                    id(substring-after($ref, '#'), root($root))//tei:persName[@type='full']
            case "author-org" return
                for $ref in $header//tei:correspAction[@type="sent"]/tei:orgName/@ref
                return
                    id(substring-after($ref, '#'), root($root))//tei:orgName
            case "language-id" return
                $header//tei:langUsage/tei:language/@ident
            case "language" return
                $header//tei:langUsage/tei:language
            case "date" return
                tokenize($header//tei:msDesc/tei:history/tei:origin/@when, '-')
            case "genre" return
                $header//tei:textClass/tei:keywords[@scheme='#type']/tei:term
            case "keyword" return
                $header//tei:textClass/tei:keywords[@scheme='#related']/tei:term
            case "persons-mentioned" return
                $header//tei:listPerson/tei:person/tei:persName[@type="full"]
            case "places-mentioned" return
                $header//tei:listPlaces/tei:place/tei:placeName
            case "organizations-mentioned" return
                $header//tei:listOrg/tei:org/tei:orgName
            case "number-in-volume" return
                $header//tei:titleStmt/tei:title/@n/number()
            default return
                ()
};
