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
 :
 : Customized for "When the Wall Came Down" (Dodis): the editorial summary serves as
 : document title, the date of origin (msDesc/history/origin/@when) as document date.
 :)
declare function idx:get-metadata($root as element(), $field as xs:string) {
    let $header := $root/tei:teiHeader
    return
        switch ($field)
            case "title" return
                let $main := ($root//tei:body//tei:head/tei:title[@type = 'main'])[1]
                let $summary := ($header//tei:msDesc/tei:msContents/tei:summary[normalize-space()])[1]
                return
                    if ($main) then
                        normalize-space(string-join($main//text()[not(ancestor::tei:note or ancestor::tei:expan)], ''))
                        => replace('\s+([,.;:])', '$1')
                    else if ($summary) then
                        normalize-space(string-join($summary//text()[not(ancestor::tei:expan)], ''))
                    else
                        string-join((
                            $header//tei:msDesc/tei:head[normalize-space()], $header//tei:titleStmt/tei:title[@type = 'main'],
                            $header//tei:titleStmt/tei:title,
                            $root/dbk:info/dbk:title,
                            root($root)//article-meta/title-group/article-title,
                            root($root)//article-meta/title-group/subtitle
                        ), " - ")
            case "author" return (
                $header//tei:correspDesc/tei:correspAction/tei:persName,
                $header//tei:titleStmt/tei:author,
                $root/dbk:info/dbk:author,
                root($root)//article-meta/contrib-group/contrib/name
            )
            case "language" return
                head((
                    $header//tei:langUsage/tei:language/@ident,
                    $root/@xml:lang,
                    $header/@xml:lang,
                    root($root)/*/@xml:lang
                ))
            case "date" return head((
                $header//tei:msDesc/tei:history/tei:origin/@when,
                $header//tei:correspDesc/tei:correspAction/tei:date/@when,
                $header//tei:sourceDesc/(tei:bibl|tei:biblFull)/tei:publicationStmt/tei:date,
                $header//tei:sourceDesc/(tei:bibl|tei:biblFull)/tei:date/@when,
                $header//tei:fileDesc/tei:editionStmt/tei:edition/tei:date,
                $header//tei:publicationStmt/tei:date
            ))
            case "genre" return (
                idx:get-genre($header),
                root($root)//dbk:info/dbk:keywordset[@role="genre"]/dbk:keyword,
                root($root)//article-meta/kwd-group[@kwd-group-type="genre"]/kwd
            )
            case "category" return
                (root($root)/tei:TEI/@n, "ZZZ")[1]
            case "feature" return (
                idx:get-classification($header, 'feature'),
                $root/dbk:info/dbk:keywordset[@role="feature"]/dbk:keyword
            )
            case "form" return (
                idx:get-classification($header, 'form'),
                $root/dbk:info/dbk:keywordset[@role="form"]/dbk:keyword
            )
            case "period" return (
                idx:get-classification($header, 'period'),
                $root/dbk:info/dbk:keywordset[@role="period"]/dbk:keyword
            )
            case "content" return (
                root($root)//body,
                $root/dbk:section
            )
            case "place" return
                (: places referenced by the document, as listed in the header (settingDesc/listPlace);
                   the name without the period in brackets, e.g. "German Democratic Republic" :)
                distinct-values(
                    for $place in root($root)//tei:teiHeader//tei:settingDesc//tei:place
                    return normalize-space(replace(($place/tei:placeName)[1], '\s*\(\d{4}-\d{4}\)', ''))
                )[. != '']
            (: facets of the chronicle: sending country, document type and referenced places (by id) :)
            case "country" return
                if ($header//tei:msDesc) then idx:country(root($root)/tei:TEI) else ()
            case "type" return
                ($header//tei:keywords[@scheme = "#type"]/tei:term)[1]/lower-case(normalize-space())[. != '']
            case "place-id" return
                distinct-values($header//tei:settingDesc//tei:place/@xml:id ! string())
            case "person" return 
                for $id in ($root//tei:persName, $root//tei:name[@type="person"], $root//tei:rs[@type='person']) 
                return 
                    (if ($id/@ref) then $id/@ref/string() else (), if ($id/@key) then $id/@key/string() else $id)
            default return
                ()
};

(:~
 : Code of the country a document was sent from, derived from the sender organisation
 : (e.g. "USA/Embassy in Bonn"), or from the original language if there is none.
 : Also used by the chronicle templates (wall:country).
 :)
declare function idx:country($doc as element(tei:TEI)) as xs:string {
    let $org := ($doc//tei:correspDesc/tei:correspAction[@type = "sent"]/tei:orgName)[1]
    (: choice/abbr and choice/expan both contribute to the string value, so
       "USA" arrives as "USA United States of America". Match the start. :)
    let $text := normalize-space(string($org))
    let $prefix := if (contains($text, "/")) then normalize-space(substring-before($text, "/")) else $text
    return
        if (matches($prefix, "^(GB|Great Britain|British)")) then "uk"
        else if (matches($prefix, "^(EDA|Swiss)")) then "ch"
        else if (matches($prefix, "^USA")) then "us"
        else if (matches($prefix, "^USSR")) then "su"
        else if (matches($prefix, "^Austria")) then "at"
        else if (matches($prefix, "^Israel")) then "il"
        else if (matches($prefix, "^Poland")) then "pl"
        else if (matches($prefix, "^Turkey")) then "tr"
        else if (matches($prefix, "^Canada")) then "ca"
        else if (matches($prefix, "^Germany")) then "de"
        else if (matches($prefix, "^Netherlands")) then "nl"
        else
            (: no sender organisation: fall back on the original language :)
            switch (($doc//tei:langUsage/tei:language/@ident)[1])
                case "ru" return "su"
                case "iw" return "il"
                case "tr" return "tr"
                case "pl" return "pl"
                case "nl" return "nl"
                default return "xx"
};

declare function idx:get-genre($header as element()?) {
    for $target in $header//tei:textClass/tei:catRef[@scheme="#genre"]/@target
    let $category := id(substring($target, 2), doc($idx:app-root || "/data/taxonomy.xml"))
    return
        $category/ancestor-or-self::tei:category[parent::tei:category]/tei:catDesc
};

declare function idx:get-classification($header as element()?, $scheme as xs:string) {
    for $target in $header//tei:textClass/tei:catRef[@scheme="#" || $scheme]/@target
    let $category := id(substring($target, 2), doc($idx:app-root || "/data/taxonomy.xml"))
    return
        $category/ancestor-or-self::tei:category[parent::tei:category]/tei:catDesc
};