import module namespace m='http://www.tei-c.org/pm/models/tei_simplePrint/latex' at '/db/apps/dodis-facets/transform/tei_simplePrint-latex.xql';

declare variable $xml external;

declare variable $parameters external;

let $options := map {
    "styles": ["../transform/tei_simplePrint.css"],
    "collection": "/db/apps/dodis-facets/transform",
    "parameters": if (exists($parameters)) then $parameters else map {}
}
return m:transform($options, $xml)