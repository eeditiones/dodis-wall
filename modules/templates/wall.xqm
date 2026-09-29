xquery version "3.1";

(:~
 : Templating functions for "When the Wall Came Down":
 : timeline strip, chronicle with filters, country overview and the
 : metadata panel of the document view.
 :)
module namespace wall="https://e-editiones.org/apps/wall-came-down/templates";

import module namespace config="http://www.tei-c.org/tei-simple/config" at "../config.xqm";
import module namespace page="http://teipublisher.com/ns/templates/page" at "page.xqm";
import module namespace idx="http://teipublisher.com/index" at "../../index.xql";
import module namespace kwic="http://exist-db.org/xquery/kwic" at "resource:org/exist/xquery/lib/kwic.xql";

declare namespace tei="http://www.tei-c.org/ns/1.0";

declare variable $wall:start := xs:date("1989-09-01");
declare variable $wall:end := xs:date("1990-11-30");

(:~ Key historical events shown alongside the documents :)
declare variable $wall:events := (
    map { "date": "1989-09-11", "en": "Hungary opens its border to Austria for GDR citizens", "de": "Ungarn öffnet die Grenze nach Österreich für DDR-Bürger" },
    map { "date": "1989-10-09", "en": "Monday demonstration in Leipzig", "de": "Montagsdemonstration in Leipzig" },
    map { "date": "1989-10-18", "en": "Honecker is replaced by Egon Krenz as SED General Secretary", "de": "Honecker wird als SED-Generalsekretär von Egon Krenz abgelöst" },
    map { "date": "1989-11-09", "en": "The Berlin Wall opens", "de": "Die Berliner Mauer fällt", "key": true() },
    map { "date": "1989-11-28", "en": "Kohl presents his Ten-Point Plan", "de": "Kohl legt sein Zehn-Punkte-Programm vor" },
    map { "date": "1989-12-22", "en": "The Brandenburg Gate reopens", "de": "Öffnung des Brandenburger Tors" },
    map { "date": "1990-02-13", "en": "Ottawa: agreement on the Two-plus-Four talks", "de": "Ottawa: Einigung auf Zwei-plus-Vier-Gespräche" },
    map { "date": "1990-03-18", "en": "First free elections to the GDR People’s Chamber", "de": "Erste freie Volkskammerwahl in der DDR" },
    map { "date": "1990-05-05", "en": "First Two-plus-Four ministerial meeting in Bonn", "de": "Erstes Zwei-plus-Vier-Außenministertreffen in Bonn" },
    map { "date": "1990-07-01", "en": "Monetary, economic and social union enters into force", "de": "Währungs-, Wirtschafts- und Sozialunion tritt in Kraft" },
    map { "date": "1990-07-16", "en": "Arkhyz, Caucasus: Kohl and Gorbachev agree on a united Germany in NATO", "de": "Archys, Kaukasus: Kohl und Gorbatschow einigen sich auf ein vereintes Deutschland in der NATO" },
    map { "date": "1990-08-31", "en": "Unification Treaty signed", "de": "Einigungsvertrag unterzeichnet" },
    map { "date": "1990-09-12", "en": "Two-plus-Four Treaty signed in Moscow", "de": "Zwei-plus-Vier-Vertrag in Moskau unterzeichnet" },
    map { "date": "1990-10-03", "en": "German reunification", "de": "Tag der Deutschen Einheit", "key": true() },
    map { "date": "1990-11-14", "en": "German–Polish Border Treaty signed", "de": "Deutsch-polnischer Grenzvertrag unterzeichnet" }
);

declare variable $wall:countries := map {
    "at": map { "en": "Austria", "de": "Österreich" },
    "ca": map { "en": "Canada", "de": "Kanada" },
    "ch": map { "en": "Switzerland", "de": "Schweiz" },
    "de": map { "en": "Federal Republic of Germany", "de": "Bundesrepublik Deutschland" },
    "il": map { "en": "Israel", "de": "Israel" },
    "nl": map { "en": "Netherlands", "de": "Niederlande" },
    "pl": map { "en": "Poland", "de": "Polen" },
    "su": map { "en": "Soviet Union", "de": "Sowjetunion" },
    "tr": map { "en": "Turkey", "de": "Türkei" },
    "uk": map { "en": "United Kingdom", "de": "Großbritannien" },
    "us": map { "en": "United States", "de": "USA" },
    "xx": map { "en": "Other", "de": "Andere" }
};

declare variable $wall:labels := map {
    "date": map { "en": "Date", "de": "Datum" },
    "type": map { "en": "Type", "de": "Dokumenttyp" },
    "from": map { "en": "From", "de": "Absender" },
    "to": map { "en": "To", "de": "Empfänger" },
    "country": map { "en": "Country", "de": "Land" },
    "lang": map { "en": "Original language", "de": "Originalsprache" },
    "persons": map { "en": "Persons", "de": "Personen" },
    "places": map { "en": "Places", "de": "Orte" },
    "cite": map { "en": "Source", "de": "Quelle" },
    "summary": map { "en": "Summary", "de": "Regest" },
    "read": map { "en": "Read document", "de": "Dokument lesen" },
    "urgent": map { "en": "Urgent", "de": "Dringend" },
    "normal": map { "en": "Normal", "de": "Normal" },
    "telegram": map { "en": "Telegram", "de": "Telegramm" },
    "memo": map { "en": "Memo", "de": "Aufzeichnung" },
    "letter": map { "en": "Letter", "de": "Brief" },
    "political report": map { "en": "Political report", "de": "Politischer Bericht" },
    "minutes": map { "en": "Minutes", "de": "Protokoll" },
    "report": map { "en": "Report", "de": "Bericht" },
    "journal": map { "en": "Journal", "de": "Tagebuch" },
    "declaration": map { "en": "Declaration", "de": "Erklärung" },
    "interview": map { "en": "Interview", "de": "Interview" },
    "de": map { "en": "German", "de": "Deutsch" },
    "en": map { "en": "English", "de": "Englisch" },
    "fr": map { "en": "French", "de": "Französisch" },
    "iw": map { "en": "Hebrew", "de": "Hebräisch" },
    "he": map { "en": "Hebrew", "de": "Hebräisch" },
    "nl": map { "en": "Dutch", "de": "Niederländisch" },
    "pl": map { "en": "Polish", "de": "Polnisch" },
    "ru": map { "en": "Russian", "de": "Russisch" },
    "tr": map { "en": "Turkish", "de": "Türkisch" }
};

declare variable $wall:texts := map {
    "kicker": map { "en": "Diplomatic documents · 1989–1990", "de": "Diplomatische Dokumente · 1989–1990" },
    "subtitle": map {
        "en": "The perception of German reunification in international diplomatic documents",
        "de": "Die Wahrnehmung der deutschen Wiedervereinigung in internationalen diplomatischen Dokumenten"
    },
    "explore": map { "en": "Explore the documents", "de": "Zu den Dokumenten" },
    "chronicle": map { "en": "Chronicle", "de": "Chronik" },
    "chronicle-intro": map {
        "en": "A selection of telegrams, memos, minutes and letters from embassies and foreign ministries in eleven countries, set against the events from autumn 1989 to German unity.",
        "de": "Eine Auswahl von Telegrammen, Aufzeichnungen, Protokollen und Briefen aus Botschaften und Außenministerien in elf Ländern – vor dem Hintergrund der Ereignisse vom Herbst 1989 bis zur Deutschen Einheit."
    },
    "voices": map { "en": "Eleven countries", "de": "Elf Länder" },
    "voices-intro": map {
        "en": "Each country contributed a selection of documents on how it saw the fall of the Wall and German reunification. Choose a country to follow its documents through the chronicle.",
        "de": "Jedes Land hat eine Auswahl von Dokumenten beigesteuert, die zeigen, wie es den Mauerfall und die deutsche Wiedervereinigung wahrnahm. Wählen Sie ein Land, um seine Dokumente in der Chronik zu verfolgen."
    },
    "caption": map { "en": "Birgit Kinder, »Test the Best«, East Side Gallery, Berlin", "de": "Birgit Kinder, »Test the Best«, East Side Gallery, Berlin" },
    "legend-doc": map { "en": "Documents per week", "de": "Dokumente pro Woche" },
    "legend-event": map { "en": "Event", "de": "Ereignis" },
    "documents": map { "en": "documents", "de": "Dokumente" },
    "document": map { "en": "document", "de": "Dokument" },
    "stat-docs": map { "en": "Documents", "de": "Dokumente" },
    "stat-countries": map { "en": "Countries", "de": "Länder" },
    "stat-langs": map { "en": "Languages", "de": "Sprachen" },
    "stat-months": map { "en": "Months", "de": "Monate" },
    "filter-all": map { "en": "All", "de": "Alle" },
    "filter-country": map { "en": "Country", "de": "Land" },
    "filter-type": map { "en": "Type", "de": "Typ" },
    "filter-place": map { "en": "Place", "de": "Ort" },
    "place-filter-hint": map { "en": "show all documents referring to this place in the chronicle", "de": "alle Dokumente zu diesem Ort in der Chronik anzeigen" },
    "shown": map { "en": "documents shown", "de": "Dokumente angezeigt" },
    "reset": map { "en": "Reset filters", "de": "Filter zurücksetzen" },
    "filter-search": map { "en": "Search", "de": "Suche" },
    "search-placeholder": map { "en": "Search the documents …", "de": "In den Dokumenten suchen …" },
    "search-submit": map { "en": "Search", "de": "Suchen" },
    "search-clear": map { "en": "Clear search", "de": "Suche löschen" },
    "match": map { "en": "match", "de": "Treffer" },
    "matches": map { "en": "matches", "de": "Treffer" },
    "edition": map { "en": "Quaderni di Dodis 12 · Bern 2019", "de": "Quaderni di Dodis 12 · Bern 2019" }
};

(: ---------------------------------------------------------------- helpers :)

declare function wall:lang($context as map(*)) as xs:string {
    let $lang := lower-case(substring(string(page:resolve-language($context)), 1, 2))
    return if ($lang = "de") then "de" else "en"
};

declare function wall:t($context as map(*), $key as xs:string) as xs:string {
    let $entry := $wall:texts($key)
    return if (exists($entry)) then $entry(wall:lang($context)) else $key
};

declare function wall:label($key as xs:string?, $lang as xs:string) as xs:string? {
    if (empty($key) or $key = "") then ()
    else
        let $entry := $wall:labels(lower-case($key))
        return if (exists($entry)) then $entry($lang) else $key
};

declare function wall:format-date($when as xs:string?, $lang as xs:string) {
    if ($when castable as xs:date) then
        try {
            format-date(xs:date($when), if ($lang = "de") then "[D]. [MNn] [Y]" else "[D] [MNn] [Y]", $lang, (), ())
        } catch * {
            $when
        }
    else
        $when
};

declare function wall:format-month($date as xs:date, $lang as xs:string) {
    try {
        format-date($date, "[MNn] [Y]", $lang, (), ())
    } catch * {
        format-date($date, "[Y]-[M01]")
    }
};

declare function wall:documents() as element(tei:TEI)* {
    for $doc in collection($config:data-root || "/documents")/tei:TEI
    order by string(wall:when($doc)), util:document-name($doc)
    return $doc
};

(: ---------------------------------------------------------------- search and facets :)

(:~ Request parameters of the chronicle filters, each mapped to the facet dimension it filters :)
declare variable $wall:filters := map { "country": "country", "type": "type", "place": "place-id" };

(:~
 : The search query and the selected filters from the request parameters "query", "country",
 : "type" and "place", as a map with an entry for each non-empty parameter. The generated route
 : for HTML pages only declares "lang", so the parameters are read from the request itself.
 :)
declare function wall:params($context as map(*)) as map(*) {
    map:merge(
        for $name in ("query", map:keys($wall:filters))
        let $value := normalize-space(string-join(
            ($context?request?parameters($name), request:get-parameter($name, ()))[1], " "))
        where $value != ""
        return map:entry($name, $value)
    )
};

(:~
 : Run the Lucene query on the text of all documents, drilled down to the selected facet values.
 : Without a search query, all documents matching the filters are returned. The filter named
 : $except is left out, so its facet counts show the alternatives to the selected value.
 : If the query is not valid Lucene syntax, the special characters are escaped and the query
 : is run again as plain words.
 :)
declare function wall:query($params as map(*), $except as xs:string?) as element(tei:text)* {
    let $options := map {
        "leading-wildcard": "yes",
        "filter-rewrite": "yes",
        "facets": map:merge(
            for $name in map:keys($wall:filters)[not(. = $except)][map:contains($params, .)]
            return map:entry($wall:filters($name), $params($name))
        )
    }
    let $texts := collection($config:data-root || "/documents")/tei:TEI/tei:text
    let $query := $params?query
    return
        try {
            $texts[ft:query(., $query, $options)]
        } catch * {
            $texts[ft:query(., replace($query, '([+\-!(){}\[\]\^"~*?:\\/|])', '\\$1'), $options)]
        }
};

(:~
 : Current state of the chronicle: the parameters, the matching tei:text elements by document
 : name, and for each filter the facet counts as a map from value to number of documents.
 :)
declare function wall:state($context as map(*)) as map(*) {
    let $params := wall:params($context)
    let $hits := wall:query($params, ())
    return map {
        "params": $params,
        "hits": map:merge(for $hit in $hits return map:entry(util:document-name($hit), $hit)),
        "facets": map:merge(
            for $name in map:keys($wall:filters)
            let $nodes := if (map:contains($params, $name)) then wall:query($params, $name) else $hits
            return
                map:entry($name, if (exists($nodes)) then ft:facets($nodes, $wall:filters($name), ()) else map {})
        )
    }
};

(:~ Link to the chronicle with the current parameters, $name set to $value or removed if empty :)
declare function wall:url($params as map(*), $name as xs:string?, $value as xs:string?) as xs:string {
    let $query := string-join(
        for $key in ("query", "country", "type", "place")
        let $v := if ($key = $name) then $value else $params($key)
        where $v
        return $key || "=" || encode-for-uri($v),
        "&amp;"
    )
    return "chronicle.html" || (if ($query) then "?" || $query else "") || "#chronicle"
};

(:~ Documents shown in the chronicle, ordered by date :)
declare function wall:documents($state as map(*)) as element(tei:TEI)* {
    for $name in map:keys($state?hits)
    let $doc := root($state?hits($name))/tei:TEI
    order by string(wall:when($doc)), $name
    return $doc
};

(:~ KWIC fragments for the matches of the search query within a document :)
declare function wall:kwic($context as map(*), $hit as element()) {
    let $expanded := util:expand($hit, "add-exist-id=none")
    let $matches := $expanded//exist:match
    let $count := count($matches)
    return
        if ($count > 0) then
            <div class="wall-kwic">
                <p class="wall-kwic-count">{ $count || " " || wall:t($context, if ($count = 1) then "match" else "matches") }</p>
                {
                    for $match in subsequence($matches, 1, 5)
                    return
                        kwic:get-summary($expanded, $match, <config width="60" table="no"/>)
                }
            </div>
        else
            ()
};

declare function wall:when($doc as element(tei:TEI)) as xs:string? {
    ($doc/tei:teiHeader//tei:msDesc/tei:history/tei:origin/@when)[1]/string()
};

(:~ Plain text of a node: without footnotes and without the expansions of abbreviations :)
declare function wall:plain($nodes as node()*) as xs:string {
    normalize-space(string-join($nodes//text()[not(ancestor::tei:note or ancestor::tei:expan)], ""))
    => replace("\s+([,.;:])", "$1")
};

(:~ The document title as printed in the volume (body head/title[@type='main']) :)
declare function wall:title($doc as element(tei:TEI)) as xs:string? {
    let $title := wall:plain(($doc//tei:body//tei:head/tei:title[@type = "main"])[1])
    return if ($title) then $title else wall:plain(($doc//tei:msDesc/tei:head)[1])
};

declare function wall:summary($doc as element(tei:TEI)) as xs:string? {
    wall:plain(($doc//tei:msContents/tei:summary)[1])
};

declare function wall:type($doc as element(tei:TEI)) as xs:string? {
    ($doc//tei:keywords[@scheme = "#type"]/tei:term)[1]/normalize-space()
};

declare function wall:priority($doc as element(tei:TEI)) as xs:string? {
    let $p := normalize-space(($doc//tei:body//tei:opener/tei:add)[1])
    return if ($p) then $p else ()
};

declare function wall:stamp($priority as xs:string?, $lang as xs:string) {
    if ($priority) then
        let $alert := matches($priority, "secret|urgent|immediate|flash|confidential|vertraulich|vetraulich|dringend|extremely|sensitive|restricted", "i")
        return
            <span class="wall-stamp {if ($alert) then 'wall-stamp-alert' else 'wall-stamp-plain'}">{ wall:label($priority, $lang) }</span>
    else
        ()
};

declare function wall:language($doc as element(tei:TEI)) as xs:string? {
    ($doc//tei:langUsage/tei:language/@ident)[1]/string()
};

(:~ Code of the sending country; shared with the index module, which creates the country facet :)
declare function wall:country($doc as element(tei:TEI)) as xs:string {
    idx:country($doc)
};

declare function wall:country-name($code as xs:string, $lang as xs:string) as xs:string {
    let $entry := $wall:countries($code)
    return if (exists($entry)) then $entry($lang) else $code
};

declare function wall:person-name($doc as element(tei:TEI), $ref as xs:string?) as xs:string? {
    if (empty($ref)) then ()
    else
        let $id := substring-after($ref, "#")
        let $name := ($doc//tei:person[@xml:id = $id]/tei:persName[tei:surname])[1]
        return
            if ($name) then
                normalize-space(string-join(($name/tei:forename, $name/tei:surname), " "))
            else
                ()
};

declare function wall:org($name as xs:string?) as xs:string? {
    if (normalize-space($name)) then
        normalize-space(replace(replace($name, "\s*\(\d{4}-?\d*\)?\s*$", ""), "/", " · "))
    else ()
};

declare function wall:party($doc as element(tei:TEI), $type as xs:string) as xs:string* {
    let $action := $doc//tei:correspDesc/tei:correspAction[@type = $type]
    let $persons :=
        for $p in $action/tei:persName
        return (wall:person-name($doc, $p/@ref), replace(normalize-space($p), "\s*\(.*\)$", ""))[1]
    return ($persons, $action/tei:orgName ! wall:org(.))
};

(:~ Name of a place from settingDesc/listPlace, without the period in brackets :)
declare function wall:place-name($place as element(tei:place)) as xs:string {
    normalize-space(replace(($place/tei:placeName)[1], "\s*\(\d{4}-\d{4}\)", ""))
};

(:~ Places referenced in the document header (settingDesc/listPlace), by Dodis id :)
declare function wall:place-ids($doc as element(tei:TEI)) as xs:string* {
    distinct-values($doc/tei:teiHeader//tei:settingDesc//tei:place/@xml:id ! string())
};

declare function wall:link($doc as element(tei:TEI)) as xs:string {
    "documents/" || util:document-name($doc)
};

declare function wall:days($when as xs:date) as xs:integer {
    xs:integer(($when - $wall:start) div xs:dayTimeDuration("P1D"))
};

declare function wall:position($when as xs:string) as xs:decimal {
    let $total := wall:days($wall:end)
    return round-half-to-even(wall:days(xs:date($when)) div $total * 100, 2)
};

(: ---------------------------------------------------------------- timeline strip :)

(:~ Horizontal timeline: the wall as axis, documents stacked as bricks per week, events as markers :)
declare function wall:strip($context as map(*)) {
    let $lang := wall:lang($context)
    let $docs := wall:documents()[wall:when(.) castable as xs:date]
    let $total := wall:days($wall:end)
    let $weeks :=
        for $doc in $docs
        group by $week := wall:days(xs:date(wall:when($doc))) idiv 7
        order by $week
        return map { "week": $week, "docs": $doc }
    let $max := max(($weeks ! count(?docs), 1))
    return
        <div class="wall-strip" style="--wall-max: {$max}">
            <div class="wall-strip-line"></div>
            {
                for $month in 0 to 15
                let $first := $wall:start + xs:yearMonthDuration("P" || $month || "M")
                where $first le $wall:end
                return
                    <span class="wall-strip-month" style="left: {wall:position(string($first))}%">
                        { format-date($first, if (month-from-date($first) = 1 or $month = 0) then "[MNn,*-3] [Y]" else "[MNn,*-3]", $lang, (), ()) }
                    </span>
            }
            {
                for $w in $weeks
                let $first := ($w?docs ! wall:when(.))[1]
                let $monday := $wall:start + xs:dayTimeDuration("P" || ($w?week * 7) || "D")
                let $count := count($w?docs)
                return
                    <a class="wall-strip-stack" href="chronicle.html#m-{substring($first, 1, 7)}"
                        style="left: {round-half-to-even(($w?week * 7 + 3.5) div $total * 100, 2)}%"
                        title="{wall:format-date(string($monday), $lang)} ff.: {$count} {if ($count = 1) then wall:t($context, 'document') else wall:t($context, 'documents')}">
                        { for $i in 1 to $count return <span class="brick"></span> }
                    </a>
            }
            {
                for $event in $wall:events
                return
                    <a class="wall-strip-event {if ($event?key) then 'key' else ()}" href="chronicle.html#ev-{$event?date}"
                        style="left: {wall:position($event?date)}%"
                        title="{wall:format-date($event?date, $lang)}: {$event($lang)}">
                        <span class="label">{ $event($lang) }</span>
                    </a>
            }
        </div>
};

(: ---------------------------------------------------------------- landing: stats + countries :)

declare function wall:stats($context as map(*)) {
    let $docs := wall:documents()
    let $dates := sort($docs ! wall:when(.)[. castable as xs:date] ! xs:date(.))
    let $months := count(distinct-values($dates ! substring(string(.), 1, 7)))
    return
        <ul class="wall-stats">
            <li><strong>{ count($docs) }</strong><span>{ wall:t($context, 'stat-docs') }</span></li>
            <li><strong>{ count(distinct-values($docs ! wall:country(.))[. != "xx"]) }</strong><span>{ wall:t($context, 'stat-countries') }</span></li>
            <li><strong>{ count(distinct-values($docs ! wall:language(.))) }</strong><span>{ wall:t($context, 'stat-langs') }</span></li>
            <li><strong>{ $months }</strong><span>{ wall:t($context, 'stat-months') }</span></li>
        </ul>
};

declare function wall:countries($context as map(*)) {
    let $lang := wall:lang($context)
    return
        <div class="wall-countries">
        {
            for $doc in wall:documents()
            group by $code := wall:country($doc)
            let $name := wall:country-name($code, $lang)
            let $dates := sort($doc ! wall:when(.))
            order by count($doc) descending, $name
            return
                <a class="wall-country" href="chronicle.html?country={$code}#chronicle">
                    <span class="wall-country-count">{ count($doc) }</span>
                    <span class="wall-country-name">{ $name }</span>
                    <span class="wall-country-range">{ wall:format-date($dates[1], $lang) } – { wall:format-date($dates[last()], $lang) }</span>
                </a>
        }
        </div>
};

(: ---------------------------------------------------------------- chronicle :)

(:~ Filter chips of one facet: "All" plus one link per value with its count; the selected value stays visible :)
declare function wall:chips($state as map(*), $name as xs:string, $label as function(xs:string) as xs:string,
    $by-count as xs:boolean, $all as xs:string) {
    let $params := $state?params
    let $counts := $state?facets($name)
    let $selected := $params($name)
    let $values := distinct-values((map:keys($counts), $selected))
    return (
        <a class="wall-chip{ if (empty($selected)) then ' active' else () }" href="{wall:url($params, $name, ())}">{ $all }</a>,
        for $value in $values
        let $count := ($counts($value), 0)[1]
        order by
            if ($by-count) then -$count else 0,
            $label($value)
        return
            <a class="wall-chip{ if ($value = $selected) then ' active' else () }" href="{wall:url($params, $name, $value)}"
                aria-current="{ if ($value = $selected) then 'true' else 'false' }">
                { $label($value) } <span class="n">{ $count }</span>
            </a>
    )
};

(:~
 : Search and filter box of the chronicle. The filters are Lucene facets: their counts are
 : computed for the current search and the other selected filters (see wall:state).
 :)
declare function wall:filters($context as map(*)) {
    let $lang := wall:lang($context)
    let $state := wall:state($context)
    let $params := $state?params
    let $places := map:merge(
        for $place in wall:documents()/tei:teiHeader//tei:settingDesc//tei:place[@xml:id]
        group by $id := string($place/@xml:id)
        return map:entry($id, wall:place-name($place[1]))
    )
    return
        <form class="wall-filters" action="chronicle.html#chronicle" method="get" role="search">
            <div class="wall-filter-group wall-search">
                <label class="wall-filter-label" for="wall-query">{ wall:t($context, 'filter-search') }</label>
                <input type="search" id="wall-query" name="query" class="wall-search-input"
                    value="{$params?query}" placeholder="{wall:t($context, 'search-placeholder')}"/>
                <button type="submit" class="wall-chip">{ wall:t($context, 'search-submit') }</button>
                {
                    if ($params?query) then
                        <a class="wall-search-clear" href="{wall:url($params, 'query', ())}">{ wall:t($context, 'search-clear') }</a>
                    else ()
                }
            </div>
            <div class="wall-filter-group" data-filter="country">
                <span class="wall-filter-label">{ wall:t($context, 'filter-country') }</span>
                { wall:chips($state, "country", wall:country-name(?, $lang), false(), wall:t($context, 'filter-all')) }
            </div>
            <div class="wall-filter-group" data-filter="type">
                <span class="wall-filter-label">{ wall:t($context, 'filter-type') }</span>
                { wall:chips($state, "type", function($type) { wall:label($type, $lang) }, true(), wall:t($context, 'filter-all')) }
            </div>
            <div class="wall-filter-group" data-filter="place">
                <label class="wall-filter-label" for="wall-place">{ wall:t($context, 'filter-place') }</label>
                <select id="wall-place" name="place" class="wall-select{ if ($params?place) then ' active' else () }">
                    <option value="">{ wall:t($context, 'filter-all') }</option>
                    {
                        let $counts := $state?facets?place
                        for $id in distinct-values((map:keys($counts), $params?place))
                        let $name := ($places($id), $id)[1]
                        order by $name
                        return
                            <option value="{$id}">
                            { if ($id = $params?place) then attribute selected { "selected" } else () }
                            { $name } ({ ($counts($id), 0)[1] })
                            </option>
                    }
                </select>
                <noscript><button type="submit" class="wall-chip">OK</button></noscript>
            </div>
            {
                (: keep the selected chips when searching or choosing a place :)
                for $name in ("country", "type")[map:contains($params, .)]
                return <input type="hidden" name="{$name}" value="{$params($name)}"/>
            }
            <p class="wall-filter-status" aria-live="polite">
                <span class="wall-shown">{ map:size($state?hits) }</span>{ " " || wall:t($context, 'shown') }
                {
                    if (map:size($params) > 0) then
                        <a class="wall-reset" href="chronicle.html#chronicle">{ wall:t($context, 'reset') }</a>
                    else ()
                }
            </p>
        </form>
};

(:~
 : Chronicle: documents interleaved with key events and month headings, ordered by date.
 : While searching or filtering, months without matching documents are left out.
 :)
declare function wall:chronicle($context as map(*)) {
    let $lang := wall:lang($context)
    let $state := wall:state($context)
    let $filtering := map:size($state?params) > 0
    let $items := (
        for $event in $wall:events return map { "date": $event?date, "event": $event },
        for $doc in wall:documents($state) return map { "date": wall:when($doc), "doc": $doc }
    )
    return
        <ol class="wall-chronicle{ if ($filtering) then ' filtered' else () }">
        {
            for $item in $items
            group by $month := substring($item?date, 1, 7)
            order by $month
            return (
                if ($filtering and empty($item?doc)) then () else
                <li class="wall-month" id="m-{$month}">
                    <h3>{ wall:format-month(xs:date($month || "-01"), $lang) }</h3>
                </li>,
                for $i in $item
                order by $i?date, exists($i?doc)
                return
                    if (exists($i?event)) then
                        <li class="wall-event" id="ev-{$i?date}">
                            <time datetime="{$i?date}">{ wall:format-date($i?date, $lang) }</time>
                            <p class="wall-event-text"><span class="wall-event-label">{ $i?event($lang) }</span></p>
                        </li>
                    else
                        wall:card($context, $i?doc, $i?date, $lang,
                            if ($state?params?query) then $state?hits(util:document-name($i?doc)) else ())
            )
        }
        </ol>
};

declare function wall:card($context as map(*), $doc as element(tei:TEI), $when as xs:string?, $lang as xs:string,
    $hit as element()?) {
    let $type := wall:type($doc)
    let $dateline := normalize-space(($doc//tei:body//tei:opener/tei:dateline)[1])
    let $country := wall:country($doc)
    let $sender := wall:party($doc, "sent")
    let $recipient := wall:party($doc, "received")
    return
        <li class="wall-doc" data-country="{$country}" data-type="{lower-case($type)}" data-places="{string-join(wall:place-ids($doc), ' ')}">
            <time datetime="{$when}">{ wall:format-date($when, $lang) }</time>
            <article class="wall-card">
                <header>
                    <span class="wall-flag wall-flag-{$country}">{ wall:country-name($country, $lang) }</span>
                    <span class="wall-type">{ wall:label($type, $lang) }</span>
                    { wall:stamp(wall:priority($doc), $lang) }
                    <span class="wall-id">dodis.ch/{ $doc//tei:msIdentifier/tei:idno/string() }</span>
                </header>
                <h4><a href="{wall:link($doc)}">{ wall:title($doc) }</a></h4>
                {
                    let $summary := wall:summary($doc)
                    return if ($summary) then <p class="wall-card-summary">{ $summary }</p> else ()
                }
                {
                    if (exists(($sender, $recipient))) then
                        <p class="wall-route">
                            <span class="from">{ if (exists($sender)) then string-join($sender, ", ") else "–" }</span>
                            <span class="arrow" aria-hidden="true">→</span>
                            <span class="to">{ if (exists($recipient)) then string-join($recipient, ", ") else "–" }</span>
                        </p>
                    else ()
                }
                { if ($dateline) then <p class="wall-dateline">{ $dateline }</p> else () }
                { if (exists($hit)) then wall:kwic($context, $hit) else () }
                <a class="wall-read" href="{wall:link($doc)}">{ wall:label("read", $lang) }</a>
            </article>
        </li>
};

(: ---------------------------------------------------------------- document view :)

(:~
 : Metadata panel for the document view (rendered into the "before" sidebar).
 : The markup is defined by the teiHeader model for mode "metadata-panel" in wall.odd;
 : only the language dependent texts are handed over here.
 :)
declare function wall:doc-meta($context as map(*)) {
    let $content := $context?doc?content
    let $doc := if (exists($content)) then (root($content)//tei:TEI)[1] else ()
    let $lang := wall:lang($context)
    return
        if (empty($doc) or empty($doc//tei:msDesc)) then
            ()
        else
            page:transform($doc, map {
                "mode": "metadata-panel",
                "language": $lang,
                "country": wall:country($doc),
                "countries": map:merge(map:for-each($wall:countries, function($k, $v) { map { $k: $v($lang) } })),
                "labels": map:merge((
                    map:for-each($wall:labels, function($k, $v) { map { $k: $v($lang) } }),
                    map { "place-filter-hint": wall:t($context, "place-filter-hint") }
                ))
            }, $context?doc?odd || ".odd")
};
