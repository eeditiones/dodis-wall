xquery version "3.1";

declare namespace cv="http://existsolutions.com/dodis/convert";
declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace config="http://www.tei-c.org/tei-simple/config" at "config.xqm";

declare function cv:process($nodes as node()*, $metadata as map(*)) {
    for $node in $nodes
    return
        typeswitch($node)
            case document-node() return
                document {
                    cv:process($node/node(), $metadata)
                }
            case element(tei:TEI) return
                <TEI xmlns="http://www.tei-c.org/ns/1.0">
                { cv:process($node/node(), $metadata) }
                </TEI>
            case element(tei:teiHeader) return
                <teiHeader xmlns="http://www.tei-c.org/ns/1.0">
                {
                    cv:fileDesc($metadata),
                    cv:profileDesc($metadata),
                    cv:process($node/tei:revisionDesc, $metadata)
                }
                </teiHeader>
            case element() return
                element { node-name($node) } {
                    $node/@*,
                    cv:process($node/node(), $metadata)
                }
            case processing-instruction() return
                ()
            default return
                $node
};

declare function cv:fileDesc($metadata as map(*)) {
    let $volume := $metadata?data?volumes?1?volume
    return
        <fileDesc xmlns="http://www.tei-c.org/ns/1.0">
            <titleStmt>
                <title type="volume">{$volume?title}</title>
                <title n="{$metadata?data?volumes?1?numberInVolume}">{$metadata?data?title}</title>
                <author>{$volume?author}</author>
            </titleStmt>
            <publicationStmt>
                <publisher>Diplomatische Dokumente der Schweiz</publisher>
                <date>{$volume?date}</date>
                <pubPlace>{$volume?place}</pubPlace>
                <idno type="URI">{$volume?url}</idno>
                <idno type="DOI">{$volume?doi}</idno>
            </publicationStmt>
            { cv:sourceDesc($metadata) }
        </fileDesc>
};


declare function cv:sourceDesc($metadata as map(*)) {
    <sourceDesc xmlns="http://www.tei-c.org/ns/1.0">
        <msDesc>
            <msIdentifier><idno>{$metadata?data?id}</idno></msIdentifier>
            <head>{$metadata?data?title}</head>
            <msContents>
                <summary>{$metadata?data?summary}</summary>
            </msContents>
            <history>
                <origin when="{cv:date($metadata?data?documentDate)}">{$metadata?data?documentDate}</origin>
            </history>
        </msDesc>
    </sourceDesc>
};

declare function cv:profileDesc($metadata as map(*)) {
    <profileDesc xmlns="http://www.tei-c.org/ns/1.0">
        <langUsage>
            <language ident="{$metadata?data?langCode}">{$metadata?data?language}</language>
        </langUsage>
        <textClass>
            <keywords>
                <term>{$metadata?data?documentTypeText}</term>
            </keywords>
        </textClass>
        <correspDesc>
        {
            let $senderPerson := $metadata?data?relatedPersons?author?*
            let $senderOrg := $metadata?data?relatedOrganizations?author?*
            return
                if (exists($senderPerson) or exists($senderOrg)) then
                    <correspAction type="sent">
                    {
                        cv:personRef($senderPerson),
                        cv:orgRef($senderOrg)
                    }
                    </correspAction>
                else
                    ()
        }
        {
            let $sigPerson := $metadata?data?relatedPersons?signatory?*
            let $sigOrg := $metadata?data?relatedOrganizations?signatory?*
            return
                if (exists($sigPerson) or exists($sigOrg)) then
                    <correspAction type="signatory">
                    {
                        cv:personRef($sigPerson),
                        cv:orgRef($sigOrg)
                    }
                    </correspAction>
                else
                    ()
        }
        {
            let $receiverPerson := $metadata?data?relatedPersons?adressee?*
            let $receiverOrg := $metadata?data?relatedOrganizations?adressee?*
            return
                if (exists($receiverPerson) or exists($receiverOrg)) then
                    <correspAction type="received">
                    {
                        cv:personRef($receiverPerson),
                        cv:orgRef($receiverOrg)
                    }
                    </correspAction>
                else
                    ()
        }
        {
            let $receiverPerson := ($metadata?data?relatedPersons?address_of_copy?*)
            let $receiverOrg := ($metadata?data?relatedOrganizations?address_of_copy?*)
            return
                if (exists($receiverPerson) or exists($receiverOrg)) then
                    <correspAction type="received-copy">
                    {
                        cv:personRef($receiverPerson),
                        cv:orgRef($receiverOrg)
                    }
                    </correspAction>
                else
                    ()
        }
        </correspDesc>
        <particDesc>
            { cv:people($metadata) }
            { cv:organizations($metadata) }
        </particDesc>
        <settingDesc>
            { cv:places($metadata) }
        </settingDesc>
    </profileDesc>
};

declare function cv:personRef($persons) {
    for $person in $persons
    return
        <persName xmlns="http://www.tei-c.org/ns/1.0" ref="#P{$person?id}">{$person?fullName}</persName>
};

declare function cv:orgRef($orgs) {
    for $org in $orgs
    return
        <orgName xmlns="http://www.tei-c.org/ns/1.0" ref="#R{$org?id}">{$org?name}</orgName>
};

declare function cv:places($metadata as map(*)) {
    let $places :=
        for $place in array:join($metadata?data?relatedPlaces?*)?*
        group by $id := $place?id
        return
            $place[1]
    return
        <listPlace xmlns="http://www.tei-c.org/ns/1.0">
        {
            for $place in $places
            order by $place?name
            return
                <place xml:id="G{$place?id}">
                    <placeName>{$place?name}</placeName>
                    {
                        if ($place?latitude) then
                            <location>
                                <geo>{$place?latitude} {$place?longitude}</geo>
                            </location>
                        else
                            ()
                    }
                    <idno type="URI">https://dodis.ch/G{$place?id}</idno>
                </place>
        }
        </listPlace>
};

declare function cv:organizations($metadata as map(*)) {
    let $orgs :=
        for $org in array:join($metadata?data?relatedOrganizations?*)?*
        group by $id := $org?id
        return
            $org[1]
    return
        <listOrg xmlns="http://www.tei-c.org/ns/1.0">
        {
            for $org in $orgs
            order by $org?name
            return
                <org xml:id="R{$org?id}">
                    <orgName>{$org?name}</orgName>
                    <idno type="URI">https://dodis.ch/R{$org?id}</idno>
                    {
                        if ($org?placeId) then
                            <placeName ref="#G{$org?placeId}">{$org?placeText}</placeName>
                        else
                            ()
                    }
                </org>
        }
        </listOrg>
};


declare function cv:people($metadata as map(*)) {
    let $persons :=
        for $person in array:join($metadata?data?relatedPersons?*)?*
        group by $id := $person?id
        return
            $person[1]
    return
        <listPerson xmlns="http://www.tei-c.org/ns/1.0">
        {
            for $person in $persons
            order by $person?fullName
            return
                <person xml:id="P{$person?id}">
                    <persName>
                        <forename>{$person?firstName}</forename>
                        <surname>{$person?lastName}</surname>
                    </persName>
                    {
                        for $otherName in $person?names?*
                        return
                            <persName>{$otherName}</persName>
                    }
                    {
                        if ($person?dateBirth) then
                            <birth when="{cv:date($person?dateBirth)}">
                            {
                                if ($person?birthPlaceText) then
                                    <placeName>{$person?birthPlaceText}</placeName>
                                else
                                    ()
                            }
                            </birth>
                        else
                            ()
                    }
                    {
                        if ($person?dateDeath) then
                            <death when="{cv:date($person?dateDeath)}">
                            {
                                if ($person?deathPlaceText) then
                                    <placeName>{$person?deathPlaceText}</placeName>
                                else
                                    ()
                            }
                            </death>
                        else
                            ()
                    }
                    <sex>{$person?gender}</sex>
                    <idno type="URI">https://dodis.ch/P{$person?id}</idno>
                </person>
        }
        </listPerson>
};



declare function cv:date($date as xs:string) {
    let $split := tokenize($date, '\.')
    return
        string-join(
            for $token in reverse($split)
            return
                format-number($token, "00"),
            "-"
        )
};

let $output := xmldb:create-collection($config:data-root, "merged")
for $file in xmldb:get-child-resources($config:app-root || "/metadata")
let $id := substring-before($file, ".json")
let $json := util:binary-doc($config:app-root || "/metadata/" || $file)
let $metadata := parse-json(util:binary-to-string($json))
let $lang := $metadata?data?langCode
let $transcript := doc($config:data-root || "/" || $id || ".xml")
let $translation := doc($config:data-root || "/" || $id || "-en.xml")
let $xml := head(($transcript, $translation))
let $transformed := cv:process($xml, $metadata)
return
    xmldb:store($output, $id || ".xml", $transformed)
