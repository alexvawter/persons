declare namespace tei = "http://www.tei-c.org/ns/1.0";

(: for each row/record in the zoteroid file where there is no text node for the element uritype :)
for $row in fn:doc("zoteroid.xml")/root/row[not(uritype/text())]
let $author := $row/authorabbr/text()
let $title := $row/titleabbr/text()
let $zoteroid := $row/zotero/text()

(: for each zotero idno in Syriaca.org bibl records:)
(: Get bibl uri:)
let $biblURI := 
              for $biblfile in fn:collection("/db/apps/srophe-data/data/bibl/tei")//tei:idno[@type="zotero"][. = $zoteroid]
              let $uri := replace($biblfile/ancestor::tei:TEI/descendant::tei:publicationStmt/descendant::tei:idno[@type="URI"][starts-with(.,'http://syriaca.org/')]/text(),'/tei','')
              return $uri
return    
  if(count($biblURI) gt 1) then (<zotero-id>{$zoteroid}</zotero-id>, <bibl-id>{$biblURI}</bibl-id>) 
  else 
    (: for bibl nodes in each person record without a bibl URI :)
    for $bibl in fn:collection("/db/apps/srophe-data/data/persons/tei/saints/tei")//tei:person/tei:bibl[not(tei:ptr)]
    let $bibltitle := $bibl/tei:title/text()
    let $biblauthor := $bibl/tei:author/tei:persName/tei:surname/text()
    (: text() was causing the ptr to be inserted in the citedRange element, before the text node :)
    let $biblcitedrange := $bibl/tei:citedRange
  
    where 
    ($bibltitle = $title and $biblauthor = $author) 
    or ($bibltitle = $title and not(exists($biblauthor))) 
    or ($biblauthor = $author and not(exists($bibltitle)))

  
return 
  (: if you do not include the tei namespace the new element will be inserted with a blank namespace. :)
  update insert <ptr xmlns="http://www.tei-c.org/ns/1.0" target="{$biblURI}"/> preceding $biblcitedrange
