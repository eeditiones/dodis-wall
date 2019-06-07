xquery version "3.1";

(: Download the latest copies. Really, we should parse each JSON file to find whether it's 
 : the base text or the translation :)

xmldb:create-collection("/db", "dodis"),
let $base-urls := (
    "https://dodis.ch/53168",
    "https://dodis.ch/52927",
    "https://dodis.ch/52942",
    "https://dodis.ch/52957",
    "https://dodis.ch/52948",
    "https://dodis.ch/52915",
    "https://dodis.ch/52922",
    "https://dodis.ch/52911",
    "https://dodis.ch/53169",
    "https://dodis.ch/52928",
    "https://dodis.ch/53320",
    "https://dodis.ch/53321",
    "https://dodis.ch/52923",
    "https://dodis.ch/49548",
    "https://dodis.ch/52958",
    "https://dodis.ch/49563",
    "https://dodis.ch/53170",
    "https://dodis.ch/52943",
    "https://dodis.ch/52937",
    "https://dodis.ch/52918",
    "https://dodis.ch/52949",
    "https://dodis.ch/52912",
    "https://dodis.ch/53171",
    "https://dodis.ch/52929",
    "https://dodis.ch/52938",
    "https://dodis.ch/52944",
    "https://dodis.ch/52953",
    "https://dodis.ch/52950",
    "https://dodis.ch/52925",
    "https://dodis.ch/52913",
    "https://dodis.ch/52931",
    "https://dodis.ch/52951",
    "https://dodis.ch/53172",
    "https://dodis.ch/52960",
    "https://dodis.ch/52914",
    "https://dodis.ch/52281",
    "https://dodis.ch/52939",
    "https://dodis.ch/52917",
    "https://dodis.ch/52945",
    "https://dodis.ch/52952",
    "https://dodis.ch/52940",
    "https://dodis.ch/53316",
    "https://dodis.ch/53317",
    "https://dodis.ch/52282",
    "https://dodis.ch/52946",
    "https://dodis.ch/49550",
    "https://dodis.ch/53318",
    "https://dodis.ch/52920",
    "https://dodis.ch/53173",
    "https://dodis.ch/53322",
    "https://dodis.ch/53323",
    "https://dodis.ch/53324",
    "https://dodis.ch/53325",
    "https://dodis.ch/52961",
    "https://dodis.ch/52947",
    "https://dodis.ch/52930",
    "https://dodis.ch/52932",
    "https://dodis.ch/52941",
    "https://dodis.ch/53319",
    "https://dodis.ch/52963",
    "https://dodis.ch/52919",
    "https://dodis.ch/49561",
    "https://dodis.ch/53174"
    )
for $base-url in $base-urls
let $doc-number := substring-after($base-url, "https://dodis.ch/")
let $doc-group := substring($doc-number, 1, 2) || "000"
let $json-url := $base-url
let $tei-url := "https://www.dodis.ch/temporary-cache/public/xml/" || $doc-group || "/dodis-" || $doc-number || ".xml"
let $tei-en-url := "https://www.dodis.ch/temporary-cache/public/xml/" || $doc-group || "/dodis-" || $doc-number || "-en.xml"
let $scanned-pdf-url := "https://www.dodis.ch/temporary-cache/public/pdf/" || $doc-group || "/dodis-" || $doc-number || ".pdf"
let $transcribed-pdf-url := "https://www.dodis.ch/temporary-cache/public/pdf/" || $doc-group || "/dodis-" || $doc-number || "-qdd.pdf"
return
    (
    (:
    :)
    let $json := 
        hc:send-request(<hc:request href="{$json-url}" method="get"><hc:header name="Content-type" value="application/json"/></hc:request>)    
        => tail() 
    return
        try { xmldb:store("/db/dodis", $doc-number || ".json", $json) } catch * { "problem downloading " || $json-url }
    ,

    let $request := hc:send-request(<hc:request href="{$tei-url}" method="get"/>)    
    let $head := $request => head()
    let $tei := $request => tail()
    return
        if ($head/@status ne "200") then 
            $head/@status || " error downloading " || $tei-url
        else
            try { xmldb:store("/db/dodis", $doc-number || ".xml", $tei) } catch * { "problem storing " || $tei-url }
    ,
    
    let $request := hc:send-request(<hc:request href="{$tei-en-url}" method="get"/>)    
    let $head := $request => head()
    let $tei-en := $request => tail()

    return
        if ($head/@status ne "200") then 
            $head/@status || " error downloading " || $tei-en-url
        else
            try { xmldb:store("/db/dodis", $doc-number || "-en.xml", $tei-en) } catch * { "problem storing " || $tei-en-url }
    (:
    ,
    
    let $scanned-pdf := hc:send-request(<hc:request href="{$scanned-pdf}" method="get"/>)    
        => tail()
    return
        xmldb:store("/db/dodis", $doc-number || ".pdf", $scanned-pdf)
    ,
       
    let $transcribed-pdf := hc:send-request(<hc:request href="{$transcribed-pdf}" method="get"/>)    
        => tail()
    return
        xmldb:store("/db/dodis", $doc-number || "-qdd.pdf", $transcribed-pdf)
    :)
    )