import module namespace m='http://www.tei-c.org/pm/models/dodis/latex' at '/db/apps/dodis-facets/transform/dodis-latex.xql';

declare variable $xml external;

declare variable $parameters external;

let $options := map {
    "styles": ["../transform/dodis.css"],
    "collection": "/db/apps/dodis-facets/transform",
    "parameters": if (exists($parameters)) then $parameters else map {}
}
return m:transform($options, $xml)