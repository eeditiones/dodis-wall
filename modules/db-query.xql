(:
 :
 :  Copyright (C) 2017 Wolfgang Meier
 :
 :  This program is free software: you can redistribute it and/or modify
 :  it under the terms of the GNU General Public License as published by
 :  the Free Software Foundation, either version 3 of the License, or
 :  (at your option) any later version.
 :
 :  This program is distributed in the hope that it will be useful,
 :  but WITHOUT ANY WARRANTY; without even the implied warranty of
 :  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 :  GNU General Public License for more details.
 :
 :  You should have received a copy of the GNU General Public License
 :  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 :)
xquery version "3.1";

module namespace dbs="http://www.tei-c.org/tei-simple/query/docbook";

declare namespace db="http://docbook.org/ns/docbook";

import module namespace config="http://www.tei-c.org/tei-simple/config" at "config.xqm";
import module namespace nav="http://www.tei-c.org/tei-simple/navigation/docbook" at "navigation-dbk.xql";

declare variable $dbs:QUERY_OPTIONS := map {
    "leading-wildcard": "yes",
    "filter-rewrite": "yes"
};

declare function dbs:query-default($fields as xs:string+, $query as xs:string, $target-texts as xs:string*) {
    if(string($query)) then
        for $field in $fields
        return
            switch ($field)
                case "head" return
                    if ($target-texts) then
                        for $text in $target-texts
                        return
                            $config:data-root ! doc(. || "/" || $text)//db:title[ft:query(., $query, dbs:options())]
                    else
                        collection($config:data-root)//db:title[ft:query(., $query, $dbs:QUERY_OPTIONS)]
                default return
                    if ($target-texts) then
                        for $text in $target-texts
                        return
                            $config:data-root ! doc(. || "/" || $text)//db:section[ft:query(., $query, dbs:options())] |
                            $config:data-root ! doc(. || "/" || $text)//db:article[ft:query(., $query, dbs:options())]
                    else
                        collection($config:data-root)//db:section[ft:query(., $query, dbs:options())] |
                        collection($config:data-root)//db:article[ft:query(., $query, dbs:options())]
    else ()
};

declare function dbs:options() {
    map:merge((
        $dbs:QUERY_OPTIONS,
        map {
            "facets":
                map:merge((
                    for $param in request:get-parameter-names()[starts-with(., 'facet-')]
                    let $dimension := substring-after($param, 'facet-')
                    return
                        map {
                            $dimension: request:get-parameter($param, ())
                        }
                ))
        }
    ))
};

declare function dbs:autocomplete($doc as xs:string?, $fields as xs:string+, $q as xs:string) {
    for $field in $fields
    return
        switch ($field)
            case "author" return
                collection($config:data-root)/ft:index-keys-for-field("author", $q,
                    function($key, $count) {
                        $key
                    }, 30)
            case "file" return
                collection($config:data-root)/ft:index-keys-for-field("file", $q,
                    function($key, $count) {
                        $key
                    }, 30)
            case "text" return
                if ($doc) then (
                    doc($config:data-root || "/" || $doc)/util:index-keys-by-qname(xs:QName("db:section"), $q,
                        function($key, $count) {
                            $key
                        }, 30, "lucene-index"),
                    doc($config:data-root || "/" || $doc)/util:index-keys-by-qname(xs:QName("db:section"), $q,
                        function($key, $count) {
                            $key
                        }, 30, "lucene-index")
                ) else (
                    collection($config:data-root)/util:index-keys-by-qname(xs:QName("db:section"), $q,
                        function($key, $count) {
                            $key
                        }, 30, "lucene-index"),
                    collection($config:data-root)/util:index-keys-by-qname(xs:QName("db:section"), $q,
                        function($key, $count) {
                            $key
                        }, 30, "lucene-index")
                )
            case "head" return
                if ($doc) then
                    doc($config:data-root || "/" || $doc)/util:index-keys-by-qname(xs:QName("db:title"), $q,
                        function($key, $count) {
                            $key
                        }, 30, "lucene-index")
                else
                    collection($config:data-root)/util:index-keys-by-qname(xs:QName("db:title"), $q,
                        function($key, $count) {
                            $key
                        }, 30, "lucene-index")
            default return
                collection($config:data-root)/ft:index-keys-for-field("title", $q,
                    function($key, $count) {
                        $key
                    }, 30)
};

declare function dbs:query-metadata($field as xs:string, $query as xs:string, $sort as xs:string) {
    for $doc in collection($config:data-root)//db:section[ft:query(., $field || ":" || $query, map { "fields": $sort
})]     return
        root($doc)/*
};

declare function dbs:get-parent-section($node as node()) {
    ($node/self::db:article, $node/ancestor-or-self::db:section[1], $node)[1]
};

declare function dbs:get-breadcrumbs($config as map(*), $hit as element(), $parent-id as xs:string) {
    let $work := root($hit)/*
    let $work-title := nav:get-document-title($config, $work)
    return
        <div class="breadcrumbs">
            <a class="breadcrumb" href="{$parent-id}">{$work-title}</a>
            {
                for $parentDiv in $hit/ancestor-or-self::db:section[db:title]
                let $id := util:node-id($parentDiv)
                return
                    <a class="breadcrumb" href="{$parent-id}?action=search&amp;root={$id}&amp;view={$config?view}&amp;odd={$config?odd}">
                    {$parentDiv/db:title/string()}
                    </a>
            }
        </div>
};

(:~
 : Expand the given element and highlight query matches by re-running the query
 : on it.
 :)
declare function dbs:expand($data as element()) {
    let $query := session:get-attribute("apps.simple.query")
    let $field := session:get-attribute("apps.simple.field")
    let $div := $data
    let $expanded :=
        util:expand(dbs:query-default-view($div, $query, $field), "add-exist-id=all")
    return
        $expanded
};


declare %private function dbs:query-default-view($context as element()*, $query as xs:string, $fields as xs:string+) {
    for $field in $fields
    return
        switch ($field)
            case "head" return
                $context[./descendant-or-self::db:title[ft:query(., $query, $dbs:QUERY_OPTIONS)]]
            default return
                $context[./descendant-or-self::db:section[ft:query(., $query, $dbs:QUERY_OPTIONS)]] |
                $context[./descendant-or-self::db:article[ft:query(., $query, $dbs:QUERY_OPTIONS)]]
};

declare function dbs:get-current($config as map(*), $div as element()?) {
    $div
};
