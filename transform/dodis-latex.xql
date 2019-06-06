(:~

    Transformation module generated from TEI ODD extensions for processing models.
    ODD: /db/apps/dodis-facets/resources/odd/dodis.odd
 :)
xquery version "3.1";

module namespace model="http://www.tei-c.org/pm/models/dodis/latex";

declare default element namespace "http://www.tei-c.org/ns/1.0";

declare namespace xhtml='http://www.w3.org/1999/xhtml';

declare namespace xi='http://www.w3.org/2001/XInclude';

declare namespace pb='http://teipublisher.com/1.0';

import module namespace css="http://www.tei-c.org/tei-simple/xquery/css";

import module namespace latex="http://www.tei-c.org/tei-simple/xquery/functions/latex";

(:~

    Main entry point for the transformation.
    
 :)
declare function model:transform($options as map(*), $input as node()*) {
        
    let $config :=
        map:merge(($options,
            map {
                "output": ["latex","print"],
                "odd": "/db/apps/dodis-facets/resources/odd/dodis.odd",
                "apply": model:apply#2,
                "apply-children": model:apply-children#3
            }
        ))
    let $config := latex:init($config, $input)
    
    return (
        
        let $output := model:apply($config, $input)
        return
            $output
    )
};

declare function model:apply($config as map(*), $input as node()*) {
        let $parameters := 
        if (exists($config?parameters)) then $config?parameters else map {}
        let $get := 
        model:source($parameters, ?)
    return
    $input !         (
            let $node := 
                .
            return
                            typeswitch(.)
                    case element(castItem) return
                        (: Insert item, rendered as described in parent list rendition. :)
                        latex:listItem($config, ., ("tei-castItem"), ., ())
                    case element(item) return
                        latex:block($config, ., ("tei-item1", "tei-listAsP"), .)
                    case element(figure) return
                        if (head or @rendition='simple:display') then
                            latex:block($config, ., ("tei-figure1"), .)
                        else
                            latex:inline($config, ., ("tei-figure2"), .)
                    case element(teiHeader) return
                        latex:metadata($config, ., ("tei-teiHeader1"), .)
                    case element(supplied) return
                        if (parent::choice) then
                            latex:inline($config, ., ("tei-supplied1"), .)
                        else
                            if (@reason='damage') then
                                latex:inline($config, ., ("tei-supplied2"), .)
                            else
                                if (@reason='illegible' or not(@reason)) then
                                    latex:inline($config, ., ("tei-supplied3"), .)
                                else
                                    if (@reason='omitted') then
                                        latex:inline($config, ., ("tei-supplied4"), .)
                                    else
                                        latex:inline($config, ., ("tei-supplied5"), .)
                    case element(milestone) return
                        latex:inline($config, ., ("tei-milestone"), .)
                    case element(label) return
                        latex:inline($config, ., ("tei-label"), .)
                    case element(signed) return
                        if (parent::closer) then
                            latex:block($config, ., ("tei-signed1"), .)
                        else
                            latex:inline($config, ., ("tei-signed2"), .)
                    case element(pb) return
                        latex:break($config, ., css:get-rendition(., ("tei-pb")), ., 'page', (concat(if(@n) then concat(@n,' ') else '',if(@facs) then                   concat('@',@facs) else '')))
                    case element(pc) return
                        latex:inline($config, ., ("tei-pc"), .)
                    case element(anchor) return
                        latex:anchor($config, ., ("tei-anchor"), ., @xml:id)
                    case element(TEI) return
                        latex:document($config, ., ("tei-TEI"), .)
                    case element(formula) return
                        if (@rendition='simple:display') then
                            latex:block($config, ., ("tei-formula1"), .)
                        else
                            latex:inline($config, ., ("tei-formula2"), .)
                    case element(choice) return
                        if (sic and corr) then
                            latex:alternate($config, ., ("tei-choice4"), ., corr[1], sic[1])
                        else
                            if (abbr and expan) then
                                latex:alternate($config, ., ("tei-choice5"), ., expan[1], abbr[1])
                            else
                                if (orig and reg) then
                                    latex:alternate($config, ., ("tei-choice6"), ., reg[1], orig[1])
                                else
                                    $config?apply($config, ./node())
                    case element(hi) return
                        if (not(@rendition)) then
                            latex:inline($config, ., ("tei-hi", "tei-hi1"), .)
                        else
                            $config?apply($config, ./node())
                    case element(code) return
                        latex:inline($config, ., ("tei-code"), .)
                    case element(note) return
                        latex:note($config, ., ("tei-note2", "tei-note"), ., (), @n)
                    case element(dateline) return
                        latex:block($config, ., ("tei-dateline", "tei-dateline"), .)
                    case element(back) return
                        latex:block($config, ., ("tei-back"), .)
                    case element(del) return
                        latex:inline($config, ., ("tei-del"), .)
                    case element(trailer) return
                        latex:block($config, ., ("tei-trailer"), .)
                    case element(titlePart) return
                        latex:block($config, ., css:get-rendition(., ("tei-titlePart")), .)
                    case element(ab) return
                        latex:paragraph($config, ., ("tei-ab"), .)
                    case element(revisionDesc) return
                        latex:omit($config, ., ("tei-revisionDesc"), .)
                    case element(am) return
                        latex:inline($config, ., ("tei-am"), .)
                    case element(subst) return
                        latex:inline($config, ., ("tei-subst"), .)
                    case element(roleDesc) return
                        latex:block($config, ., ("tei-roleDesc"), .)
                    case element(orig) return
                        latex:inline($config, ., ("tei-orig", "tei-orig"), .)
                    case element(opener) return
                        latex:block($config, ., ("tei-opener", "tei-opener"), .)
                    case element(speaker) return
                        latex:block($config, ., ("tei-speaker"), .)
                    case element(imprimatur) return
                        latex:block($config, ., ("tei-imprimatur"), .)
                    case element(publisher) return
                        if (ancestor::teiHeader) then
                            (: Omit if located in teiHeader. :)
                            latex:omit($config, ., ("tei-publisher"), .)
                        else
                            $config?apply($config, ./node())
                    case element(figDesc) return
                        latex:inline($config, ., ("tei-figDesc"), .)
                    case element(rs) return
                        latex:inline($config, ., ("tei-rs"), .)
                    case element(foreign) return
                        latex:inline($config, ., ("tei-foreign"), .)
                    case element(fileDesc) return
                        if ($parameters?header='short') then
                            (
                                latex:block($config, ., ("tei-fileDesc1", "header-short"), titleStmt),
                                latex:block($config, ., ("tei-fileDesc2", "header-short"), editionStmt),
                                latex:block($config, ., ("tei-fileDesc3", "header-short"), publicationStmt)
                            )

                        else
                            latex:title($config, ., ("tei-fileDesc4"), titleStmt)
                    case element(seg) return
                        latex:inline($config, ., css:get-rendition(., ("tei-seg")), .)
                    case element(profileDesc) return
                        latex:omit($config, ., ("tei-profileDesc"), .)
                    case element(email) return
                        latex:inline($config, ., ("tei-email"), .)
                    case element(text) return
                        latex:body($config, ., ("tei-text"), .)
                    case element(floatingText) return
                        latex:inline($config, ., ("tei-floatingText", "tei-float"), .)
                    case element(sp) return
                        latex:block($config, ., ("tei-sp"), .)
                    case element(abbr) return
                        latex:inline($config, ., ("tei-abbr"), .)
                    case element(table) return
                        latex:table($config, ., ("tei-table", "tei-table"), ., map {})
                    case element(cb) return
                        latex:break($config, ., ("tei-cb"), ., 'column', @n)
                    case element(group) return
                        latex:block($config, ., ("tei-group"), .)
                    case element(licence) return
                        latex:omit($config, ., ("tei-licence2"), .)
                    case element(editor) return
                        if (ancestor::teiHeader) then
                            latex:omit($config, ., ("tei-editor1"), .)
                        else
                            latex:inline($config, ., ("tei-editor2"), .)
                    case element(c) return
                        latex:inline($config, ., ("tei-c"), .)
                    case element(listBibl) return
                        if (bibl) then
                            latex:list($config, ., ("tei-listBibl1"), bibl, ())
                        else
                            latex:block($config, ., ("tei-listBibl2"), .)
                    case element(address) return
                        latex:block($config, ., ("tei-address"), .)
                    case element(g) return
                        if (not(text())) then
                            latex:glyph($config, ., ("tei-g1"), .)
                        else
                            latex:inline($config, ., ("tei-g2"), .)
                    case element(author) return
                        if (ancestor::teiHeader) then
                            latex:block($config, ., ("tei-author1"), .)
                        else
                            latex:inline($config, ., ("tei-author2"), .)
                    case element(castList) return
                        if (child::*) then
                            latex:list($config, ., css:get-rendition(., ("tei-castList", "tei-cast")), castItem, ())
                        else
                            $config?apply($config, ./node())
                    case element(l) return
                        latex:block($config, ., css:get-rendition(., ("tei-l")), .)
                    case element(closer) return
                        latex:block($config, ., ("tei-closer"), .)
                    case element(rhyme) return
                        latex:inline($config, ., ("tei-rhyme"), .)
                    case element(list) return
                        latex:block($config, ., ("tei-list1", "asBlock"), .)
                    case element(p) return
                        latex:paragraph($config, ., ("tei-p", "tei-p"), .)
                    case element(measure) return
                        latex:inline($config, ., ("tei-measure"), .)
                    case element(q) return
                        if (l) then
                            latex:block($config, ., css:get-rendition(., ("tei-q1")), .)
                        else
                            if (ancestor::p or ancestor::cell) then
                                latex:inline($config, ., css:get-rendition(., ("tei-q2")), .)
                            else
                                latex:block($config, ., css:get-rendition(., ("tei-q3")), .)
                    case element(actor) return
                        latex:inline($config, ., ("tei-actor"), .)
                    case element(epigraph) return
                        latex:block($config, ., ("tei-epigraph"), .)
                    case element(s) return
                        latex:inline($config, ., ("tei-s"), .)
                    case element(docTitle) return
                        latex:block($config, ., css:get-rendition(., ("tei-docTitle")), .)
                    case element(lb) return
                        latex:break($config, ., css:get-rendition(., ("tei-lb")), ., 'line', @n)
                    case element(w) return
                        latex:inline($config, ., ("tei-w"), .)
                    case element(stage) return
                        latex:block($config, ., ("tei-stage"), .)
                    case element(titlePage) return
                        latex:block($config, ., css:get-rendition(., ("tei-titlePage")), .)
                    case element(name) return
                        latex:inline($config, ., ("tei-name"), .)
                    case element(front) return
                        latex:block($config, ., ("tei-front"), .)
                    case element(lg) return
                        latex:block($config, ., ("tei-lg"), .)
                    case element(publicationStmt) return
                        latex:omit($config, ., ("tei-publicationStmt2"), .)
                    case element(biblScope) return
                        latex:inline($config, ., ("tei-biblScope"), .)
                    case element(desc) return
                        latex:inline($config, ., ("tei-desc"), .)
                    case element(role) return
                        latex:block($config, ., ("tei-role"), .)
                    case element(docEdition) return
                        latex:inline($config, ., ("tei-docEdition"), .)
                    case element(num) return
                        latex:inline($config, ., ("tei-num"), .)
                    case element(docImprint) return
                        latex:inline($config, ., ("tei-docImprint"), .)
                    case element(postscript) return
                        latex:block($config, ., ("tei-postscript"), .)
                    case element(edition) return
                        if (ancestor::teiHeader) then
                            latex:block($config, ., ("tei-edition"), .)
                        else
                            $config?apply($config, ./node())
                    case element(cell) return
                        latex:cell($config, ., ("tei-cell", "tei-cell"), ., ())
                    case element(relatedItem) return
                        latex:inline($config, ., ("tei-relatedItem"), .)
                    case element(div) return
                        latex:block($config, ., ("tei-div", "tei-div"), .)
                    case element(graphic) return
                        latex:graphic($config, ., ("tei-graphic"), ., @url, @width, @height, @scale, desc)
                    case element(reg) return
                        latex:inline($config, ., ("tei-reg"), .)
                    case element(ref) return
                        if (parent::head) then
                            latex:link($config, ., ("tei-ref3", "tei-head-nr"), ., (), map {"link": if (starts-with(@target, '#')) then '?odd=' || request:get-parameter('odd', ()) || '&amp;view=' || request:get-parameter('view', ()) || '&amp;id=' || substring-after(@target, '#') else @target})
                        else
                            if (not(@target)) then
                                latex:inline($config, ., ("tei-ref5", "tei-ref1"), .)
                            else
                                $config?apply($config, ./node())
                    case element(pubPlace) return
                        if (ancestor::teiHeader) then
                            (: Omit if located in teiHeader. :)
                            latex:omit($config, ., ("tei-pubPlace"), .)
                        else
                            $config?apply($config, ./node())
                    case element(add) return
                        if (@type='edition') then
                            latex:inline($config, ., ("tei-add1", "tei-add-edition"), .)
                        else
                            if (parent::opener) then
                                latex:inline($config, ., ("tei-add2", "tei-add-opener"), .)
                            else
                                $config?apply($config, ./node())
                    case element(docDate) return
                        latex:inline($config, ., ("tei-docDate"), .)
                    case element(head) return
                        if ($parameters?header='short') then
                            latex:inline($config, ., ("tei-head1"), replace(string-join(.//text()[not(parent::ref)]), '^(.*?)[^\w]*$', '$1'))
                        else
                            if (parent::figure) then
                                latex:block($config, ., ("tei-head2"), .)
                            else
                                if (parent::table) then
                                    latex:block($config, ., ("tei-head3"), .)
                                else
                                    if (parent::lg) then
                                        latex:block($config, ., ("tei-head4"), .)
                                    else
                                        if (parent::list) then
                                            latex:block($config, ., ("tei-head5"), .)
                                        else
                                            if (parent::div) then
                                                latex:heading($config, ., ("tei-head6", "tei-head-div"), ., count(ancestor::div))
                                            else
                                                latex:block($config, ., ("tei-head7"), .)
                    case element(ex) return
                        latex:inline($config, ., ("tei-ex"), .)
                    case element(castGroup) return
                        if (child::*) then
                            (: Insert list. :)
                            latex:list($config, ., ("tei-castGroup"), castItem|castGroup, ())
                        else
                            $config?apply($config, ./node())
                    case element(time) return
                        latex:inline($config, ., ("tei-time"), .)
                    case element(bibl) return
                        if (parent::listBibl) then
                            latex:listItem($config, ., ("tei-bibl1"), ., ())
                        else
                            latex:inline($config, ., ("tei-bibl2"), .)
                    case element(salute) return
                        if (parent::closer) then
                            latex:inline($config, ., ("tei-salute1"), .)
                        else
                            latex:block($config, ., ("tei-salute2"), .)
                    case element(unclear) return
                        latex:inline($config, ., ("tei-unclear"), .)
                    case element(argument) return
                        latex:block($config, ., ("tei-argument"), .)
                    case element(date) return
                        if (text()) then
                            latex:inline($config, ., ("tei-date1"), .)
                        else
                            if (@when and not(text())) then
                                latex:inline($config, ., ("tei-date2"), @when)
                            else
                                if (text()) then
                                    latex:inline($config, ., ("tei-date4", "tei-date"), .)
                                else
                                    $config?apply($config, ./node())
                    case element(title) return
                        if (@type='doc') then
                            latex:block($config, ., ("tei-title3", "tei-title-doc"), .)
                        else
                            if (@type='main') then
                                latex:inline($config, ., ("tei-title5", "tei-title-main"), .)
                            else
                                $config?apply($config, ./node())
                    case element(corr) return
                        if (parent::choice and count(parent::*/*) gt 1) then
                            (: simple inline, if in parent choice. :)
                            latex:inline($config, ., ("tei-corr1"), .)
                        else
                            latex:inline($config, ., ("tei-corr2"), .)
                    case element(cit) return
                        if (child::quote and child::bibl) then
                            (: Insert citation :)
                            latex:cit($config, ., ("tei-cit"), ., ())
                        else
                            $config?apply($config, ./node())
                    case element(titleStmt) return
                        (: No function found for behavior: meta :)
                        $config?apply($config, ./node())
                    case element(sic) return
                        if (parent::choice and count(parent::*/*) gt 1) then
                            latex:inline($config, ., ("tei-sic1"), .)
                        else
                            latex:inline($config, ., ("tei-sic2"), .)
                    case element(expan) return
                        latex:inline($config, ., ("tei-expan"), .)
                    case element(body) return
                        (
                            latex:index($config, ., ("tei-body1"), ., 'toc'),
                            latex:block($config, ., ("tei-body2"), .)
                        )

                    case element(spGrp) return
                        latex:block($config, ., ("tei-spGrp"), .)
                    case element(fw) return
                        if (ancestor::p or ancestor::ab) then
                            latex:inline($config, ., ("tei-fw1"), .)
                        else
                            latex:block($config, ., ("tei-fw2"), .)
                    case element(encodingDesc) return
                        latex:omit($config, ., ("tei-encodingDesc"), .)
                    case element(addrLine) return
                        latex:block($config, ., ("tei-addrLine"), .)
                    case element(gap) return
                        if (desc) then
                            latex:inline($config, ., ("tei-gap1"), .)
                        else
                            if (@extent) then
                                latex:inline($config, ., ("tei-gap2"), @extent)
                            else
                                latex:inline($config, ., ("tei-gap3"), .)
                    case element(quote) return
                        if (ancestor::p) then
                            (: If it is inside a paragraph then it is inline, otherwise it is block level :)
                            latex:inline($config, ., css:get-rendition(., ("tei-quote1")), .)
                        else
                            (: If it is inside a paragraph then it is inline, otherwise it is block level :)
                            latex:block($config, ., css:get-rendition(., ("tei-quote2")), .)
                    case element(row) return
                        latex:row($config, ., ("tei-row", "tei-row"), .)
                    case element(docAuthor) return
                        latex:inline($config, ., ("tei-docAuthor"), .)
                    case element(byline) return
                        latex:block($config, ., ("tei-byline"), .)
                    case element(idno) return
                        latex:inline($config, ., ("tei-idno", "tei-idno"), .)
                    case element(span) return
                        latex:inline($config, ., ("tei-span", "tei-span"), .)
                    case element(emph) return
                        latex:inline($config, ., ("tei-emph", "tei-emph"), .)
                    case element() return
                        if (namespace-uri(.) = 'http://www.tei-c.org/ns/1.0') then
                            $config?apply($config, ./node())
                        else
                            .
                    case text() | xs:anyAtomicType return
                        latex:escapeChars(.)
                    default return 
                        $config?apply($config, ./node())

        )

};

declare function model:apply-children($config as map(*), $node as element(), $content as item()*) {
        
    if ($config?template) then
        $content
    else
        $content ! (
            typeswitch(.)
                case element() return
                    if (. is $node) then
                        $config?apply($config, ./node())
                    else
                        $config?apply($config, .)
                default return
                    latex:escapeChars(.)
        )
};

declare function model:source($parameters as map(*), $elem as element()) {
        
    let $id := $elem/@exist:id
    return
        if ($id and $parameters?root) then
            util:node-by-id($parameters?root, $id)
        else
            $elem
};

